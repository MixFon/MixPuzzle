//
//  InversionView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 19.05.2025.
//

import SwiftUI
import MFPuzzle

final class InversionViewRouter: ObservableObject {
	@Published var toSandbox = false
}

/// Урок «почему решения может не быть» в 4 шага: сверху поле-пример,
/// снизу панель с текстом шага. С последнего шага (и из шапки) — песочница.
struct InversionView: View {

	let checker: _Checker
	let matrixWorker: _MatrixWorker

	@StateObject private var router = InversionViewRouter()

	/// Пример: по строкам три инверсии (3›1, 3›2, 8›7), «змейкой» — шесть
	private static let example: [MatrixElement] = [3, 1, 2, 4, 5, 6, 8, 7, 0]
	private let size = 3
	private let stepsCount = 4

	@State private var step = 0
	@State private var cells: [MatrixElement] = InversionView.example
	/// Какую пару-пример подсвечиваем на первом шаге
	@State private var exampleIndex = 0
	/// Изменилась ли чётность после последнего действия на третьем шаге
	@State private var lastChangeFlipped: Bool?

	var body: some View {
		SettingsPreviewLayout(
			title: "mix.inversion.title".localized,
			panelTitle: String(format: "mix.inversion.step".localized, self.step + 1, self.stepsCount),
			isPanelResizable: false
		) {
			Button {
				self.router.toSandbox = true
			} label: {
				Image(systemName: "hand.tap")
					.font(.body.weight(.semibold))
					.foregroundStyle(Color.mm_text_primary)
					.frame(width: 44, height: 44)
					.glassBackground(in: Circle())
			}
			.buttonStyle(.plain)
			.accessibilityLabel("mix.inversion.try".localized)
		} preview: {
			InversionLessonBoardArea(
				cells: self.cells,
				size: self.size,
				highlighted: self.highlightedIndices,
				showsSnake: self.step == 1,
				sequence: self.sequence,
				sequenceHighlight: self.sequenceHighlight,
				status: self.statusText,
				statusColor: self.statusColor
			)
		} panel: {
			self.panelContent
		}
		.task(id: self.step) {
			await self.cycleExamples()
		}
		.fullScreenCover(isPresented: self.$router.toSandbox) {
			InversionSandboxView()
		}
	}

	// MARK: Панель

	private var panelContent: some View {
		VStack(alignment: .leading, spacing: 12) {
			ScrollView {
				VStack(alignment: .leading, spacing: 12) {
					self.stepDots
					Text(self.stepTitle)
						.font(.title3.weight(.heavy))
						.foregroundStyle(Color.mm_text_primary)
					Text(self.stepText)
						.font(.subheadline)
						.foregroundStyle(Color.mm_text_secondary)
						.fixedSize(horizontal: false, vertical: true)
					if self.step == 0 {
						self.examplePairs
					}
					if self.step == 2 {
						self.parityActions
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
			}
			HStack(spacing: 10) {
				if self.step > 0 {
					Button {
						self.go(to: self.step - 1)
					} label: {
						Text("mix.inversion.back".localized)
							.font(.body.weight(.semibold))
							.foregroundStyle(Color.mm_text_primary)
							.padding(.horizontal, 20)
							.frame(minHeight: 50)
							.background(Color.mm_background_secondary, in: Capsule())
					}
					.buttonStyle(.plain)
				}
				Button {
					if self.step < self.stepsCount - 1 {
						self.go(to: self.step + 1)
					} else {
						self.router.toSandbox = true
					}
				} label: {
					Text(self.step < self.stepsCount - 1 ? "mix.inversion.next".localized : "mix.inversion.try".localized)
						.font(.body.weight(.bold))
						.foregroundStyle(Color.white)
						.frame(maxWidth: .infinity, minHeight: 50)
						.background(Color.mm_tint_secondary, in: Capsule())
				}
				.buttonStyle(.plain)
			}
			.padding(.bottom, 8)
		}
	}

	private var stepDots: some View {
		HStack(spacing: 8) {
			ForEach(0..<self.stepsCount, id: \.self) { index in
				Button {
					self.go(to: index)
				} label: {
					Capsule()
						.fill(index == self.step ? Color.mm_tint_secondary : Color.mm_text_secondary.opacity(0.4))
						.frame(width: index == self.step ? 24 : 8, height: 8)
						.frame(height: 24)
						.contentShape(Rectangle())
				}
				.buttonStyle(.plain)
				.accessibilityLabel(String(format: "mix.inversion.step".localized, index + 1, self.stepsCount))
			}
		}
		.animation(.easeInOut(duration: 0.2), value: self.step)
	}

	/// Чипы с парами-инверсиями первого шага: подсвечиваются по очереди, тап выбирает пару
	private var examplePairs: some View {
		HStack(spacing: 8) {
			ForEach(Array(self.rowPairs.enumerated()), id: \.offset) { index, pair in
				Button {
					self.exampleIndex = index
				} label: {
					Text("\(pair.greater) › \(pair.smaller)")
						.font(.subheadline.weight(.semibold))
						.foregroundStyle(index == self.exampleIndex ? Color.white : Color.mm_text_primary)
						.padding(.horizontal, 12)
						.frame(minHeight: 36)
						.background(index == self.exampleIndex ? Color.mm_warning : Color.mm_background_secondary, in: Capsule())
				}
				.buttonStyle(.plain)
			}
		}
		.animation(.easeInOut(duration: 0.2), value: self.exampleIndex)
	}

	private var parityActions: some View {
		HStack(spacing: 8) {
			self.actionButton(title: "mix.inversion.move.blank".localized) {
				self.moveBlank()
			}
			self.actionButton(title: "mix.inversion.swap.two".localized) {
				self.swapTwo()
			}
		}
	}

	private func actionButton(title: String, action: @escaping () -> Void) -> some View {
		Button(action: action) {
			Text(title)
				.font(.subheadline.weight(.semibold))
				.foregroundStyle(Color.mm_text_primary)
				.lineLimit(1)
				.minimumScaleFactor(0.8)
				.frame(maxWidth: .infinity, minHeight: 44)
				.background(Color.mm_background_secondary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
		}
		.buttonStyle(.plain)
	}

	// MARK: Содержимое шагов

	private var stepTitle: String {
		["mix.inversion.step1.title", "mix.inversion.step2.title", "mix.inversion.step3.title", "mix.inversion.step4.title"][self.step].localized
	}

	private var stepText: String {
		switch self.step {
		case 0:
			let list = self.rowPairs.map { "\($0.greater) › \($0.smaller)" }.joined(separator: ", ")
			return String(format: "mix.inversion.step1.text".localized, self.rowPairs.count, list)
		case 1:
			return String(format: "mix.inversion.step2.text".localized, self.snakeCount)
		case 2:
			return "mix.inversion.step3.text".localized
		default:
			return "mix.inversion.step4.text".localized
		}
	}

	private var rowPairs: [InversionPair] {
		InversionMath.pairs(in: InversionMath.sequence(self.cells, size: self.size, snake: false))
	}

	private var snakeCount: Int {
		InversionMath.count(self.cells, size: self.size)
	}

	private var targetCount: Int {
		let target = self.matrixWorker.createMatrixSolution(size: self.size, solution: .classic).flatMap { $0 }
		return InversionMath.count(target.isEmpty ? InversionMath.solved(size: self.size) : target, size: self.size)
	}

	private var currentPair: InversionPair? {
		let pairs = self.rowPairs
		guard !pairs.isEmpty else { return nil }
		return pairs[self.exampleIndex % pairs.count]
	}

	private var highlightedIndices: Set<Int> {
		guard self.step == 0, let pair = self.currentPair else { return [] }
		return Set([pair.greater, pair.smaller].compactMap { self.cells.firstIndex(of: $0) })
	}

	/// Строка чисел под полем: по строкам на первом шаге, змейкой на втором
	private var sequence: [MatrixElement]? {
		switch self.step {
		case 0:
			return InversionMath.sequence(self.cells, size: self.size, snake: false)
		case 1:
			return InversionMath.sequence(self.cells, size: self.size, snake: true)
		default:
			return nil
		}
	}

	private var sequenceHighlight: Set<MatrixElement> {
		guard self.step == 0, let pair = self.currentPair else { return [] }
		return [pair.greater, pair.smaller]
	}

	private var statusText: String {
		let parity = Self.parityName(self.snakeCount)
		switch self.step {
		case 0:
			return String(format: "mix.inversion.status.rows".localized, self.rowPairs.count)
		case 1:
			return String(format: "mix.inversion.status.snake".localized, self.snakeCount, parity)
		case 2:
			let base = String(format: "mix.inversion.status.snake".localized, self.snakeCount, parity)
			guard let flipped = self.lastChangeFlipped else { return base }
			return base + " — " + (flipped ? "mix.inversion.changed".localized : "mix.inversion.unchanged".localized)
		default:
			let verdict = self.isSameParity ? "mix.inversion.verdict.yes".localized : "mix.inversion.verdict.no".localized
			return String(format: "mix.inversion.status.compare".localized, self.snakeCount, self.targetCount) + " — " + verdict
		}
	}

	private var statusColor: Color {
		switch self.step {
		case 0:
			return .mm_warning
		case 3:
			return self.isSameParity ? .mm_green : .mm_danger
		default:
			return self.snakeCount % 2 == 0 ? .mm_green : .mm_warning
		}
	}

	private var isSameParity: Bool {
		self.snakeCount % 2 == self.targetCount % 2
	}

	static func parityName(_ count: Int) -> String {
		count % 2 == 0 ? "mix.inversion.even".localized : "mix.inversion.odd".localized
	}

	// MARK: Действия

	private func go(to step: Int) {
		withAnimation(.easeInOut(duration: 0.25)) {
			self.step = min(max(step, 0), self.stepsCount - 1)
			self.lastChangeFlipped = nil
			// На первых двух шагах объясняем на исходном примере
			if self.step < 2 {
				self.cells = Self.example
			}
		}
	}

	/// На первом шаге пары-примеры подсвечиваются по очереди
	private func cycleExamples() async {
		guard self.step == 0 else { return }
		while !Task.isCancelled {
			try? await Task.sleep(nanoseconds: 1_800_000_000)
			guard !Task.isCancelled, self.step == 0 else { return }
			withAnimation(.easeInOut(duration: 0.2)) {
				self.exampleIndex += 1
			}
		}
	}

	private func moveBlank() {
		guard let blank = self.cells.firstIndex(of: 0),
			  let neighbor = InversionMath.neighborsOfBlank(self.cells, size: self.size).randomElement() else { return }
		self.apply { $0.swapAt(blank, neighbor) }
	}

	private func swapTwo() {
		let tiles = self.cells.indices.filter { self.cells[$0] != 0 }.shuffled()
		guard tiles.count >= 2 else { return }
		self.apply { $0.swapAt(tiles[0], tiles[1]) }
	}

	private func apply(_ change: (inout [MatrixElement]) -> Void) {
		let before = self.snakeCount % 2
		withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
			change(&self.cells)
		}
		self.lastChangeFlipped = before != self.snakeCount % 2
	}
}

/// Область над панелью: поле, строка чисел и плашка состояния
private struct InversionLessonBoardArea: View {
	let cells: [MatrixElement]
	let size: Int
	let highlighted: Set<Int>
	let showsSnake: Bool
	let sequence: [MatrixElement]?
	let sequenceHighlight: Set<MatrixElement>
	let status: String
	let statusColor: Color

	@Environment(\.settingsHeaderInset) private var headerInset

	var body: some View {
		VStack(spacing: 14) {
			InversionBoardView(cells: self.cells, size: self.size, tileSide: 64, highlighted: self.highlighted, showsSnake: self.showsSnake)
			if let sequence = self.sequence {
				HStack(spacing: 4) {
					ForEach(Array(sequence.enumerated()), id: \.offset) { _, value in
						let isOn = self.sequenceHighlight.contains(value)
						Text("\(value)")
							.font(.subheadline.weight(.bold))
							.monospacedDigit()
							.foregroundStyle(isOn ? Color.white : Color.mm_text_primary)
							.frame(width: 28, height: 28)
							.background(isOn ? Color.mm_warning : Color.mm_text_primary.opacity(0.1), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
					}
				}
				.accessibilityElement(children: .combine)
				.transition(.opacity)
			}
			HStack(spacing: 8) {
				Circle()
					.fill(self.statusColor)
					.frame(width: 10, height: 10)
				Text(self.status)
					.font(.subheadline.weight(.semibold))
					.foregroundStyle(Color.mm_text_primary)
					.lineLimit(1)
					.minimumScaleFactor(0.7)
			}
			.padding(.horizontal, 14)
			.frame(minHeight: 36)
			.glassBackground(in: Capsule())
			.accessibilityElement(children: .combine)
		}
		.padding(.top, self.headerInset + 8)
		.padding(.horizontal, 16)
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
		.background(Color.black)
	}
}

#Preview {
	InversionView(checker: MockChecker(), matrixWorker: MockMatrixWorker())
}
