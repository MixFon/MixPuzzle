//
//  InversionSandboxView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 07.11.2026.
//

import SwiftUI
import MFPuzzle

/// Песочница чётности: по полю можно ходить как в игре (тап по соседней с пустой плитке),
/// а тап по двум другим плиткам меняет их местами. Счётчик инверсий и лента ходов
/// показывают, когда чётность меняется, а когда нет.
struct InversionSandboxView: View {

	/// Запись в ленте ходов
	private struct LogEntry: Identifiable, Equatable {
		let id = UUID()
		let text: String
		let flipped: Bool
	}

	private let sizes = [3, 4]

	@State private var size = 3
	@State private var cells: [MatrixElement] = [1, 2, 3, 4, 5, 6, 8, 7, 0]
	@State private var selected: Int?
	@State private var showsSnake = true
	@State private var log: [LogEntry] = []

	var body: some View {
		SettingsPreviewLayout(
			title: "mix.sandbox.title".localized,
			panelTitle: "mix.sandbox.panel".localized,
			isPanelResizable: false
		) {
			Button {
				self.showsSnake.toggle()
			} label: {
				Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
					.font(.body.weight(.semibold))
					.foregroundStyle(self.showsSnake ? Color.white : Color.mm_text_primary)
					.frame(width: 44, height: 44)
					.glassBackground(in: Circle(), tint: self.showsSnake ? .mm_tint_secondary : nil)
			}
			.buttonStyle(.plain)
			.accessibilityLabel("mix.sandbox.snake".localized)
			.accessibilityAddTraits(self.showsSnake ? .isSelected : [])
		} preview: {
			SandboxBoardArea(
				sizes: self.sizes,
				size: self.size,
				cells: self.cells,
				selected: self.selected,
				showsSnake: self.showsSnake,
				onSize: { self.setSize($0) },
				onTap: { self.tap($0) }
			)
		} panel: {
			self.panelContent
		}
	}

	// MARK: Панель

	private var panelContent: some View {
		let count = InversionMath.count(self.cells, size: self.size)
		let isOdd = count % 2 == 1
		return VStack(spacing: 12) {
			HStack(alignment: .center) {
				VStack(alignment: .leading, spacing: 2) {
					Text("mix.sandbox.inversions".localized)
						.font(.caption.weight(.semibold))
						.foregroundStyle(Color.mm_text_secondary)
						.textCase(.uppercase)
					Text("\(count)")
						.font(.system(size: 34, weight: .heavy, design: .rounded))
						.monospacedDigit()
						.foregroundStyle(Color.mm_text_primary)
				}
				Spacer()
				Text(InversionView.parityName(count))
					.font(.headline.weight(.heavy))
					.foregroundStyle(isOdd ? Color.mm_warning : Color.mm_green)
					.padding(.horizontal, 18)
					.frame(minHeight: 40)
					.background((isOdd ? Color.mm_warning : Color.mm_green).opacity(0.18), in: Capsule())
			}
			.accessibilityElement(children: .combine)
			.animation(.easeInOut(duration: 0.25), value: isOdd)

			ScrollView {
				VStack(spacing: 6) {
					if self.log.isEmpty {
						self.logRow(text: "mix.sandbox.log.empty".localized, color: Color.mm_text_secondary.opacity(0.5), isLatest: false)
					}
					ForEach(Array(self.log.enumerated()), id: \.element.id) { index, entry in
						self.logRow(text: entry.text, color: entry.flipped ? .mm_warning : .mm_green, isLatest: index == 0)
							.transition(.move(edge: .top).combined(with: .opacity))
					}
				}
			}

			Text("mix.sandbox.hint".localized)
				.font(.footnote)
				.foregroundStyle(Color.mm_text_secondary)
				.multilineTextAlignment(.center)
				.fixedSize(horizontal: false, vertical: true)
			HStack(spacing: 10) {
				self.actionButton(title: "mix.inversion.move.blank".localized) {
					if let neighbor = InversionMath.neighborsOfBlank(self.cells, size: self.size).randomElement() {
						self.slide(neighbor)
					}
				}
				self.actionButton(title: "mix.sandbox.swap.random".localized) {
					let tiles = self.cells.indices.filter { self.cells[$0] != 0 }.shuffled()
					if tiles.count >= 2 {
						self.swap(tiles[0], tiles[1])
					}
				}
			}
			.padding(.bottom, 8)
		}
	}

	private func logRow(text: String, color: Color, isLatest: Bool) -> some View {
		HStack(spacing: 10) {
			Circle()
				.fill(color)
				.frame(width: 8, height: 8)
			Text(text)
				.font(.subheadline)
				.foregroundStyle(isLatest ? Color.mm_text_primary : Color.mm_text_secondary)
				.lineLimit(2)
			Spacer(minLength: 0)
		}
		.padding(.horizontal, 12)
		.frame(minHeight: 36)
		.background(Color.mm_background_secondary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
	}

	private func actionButton(title: String, action: @escaping () -> Void) -> some View {
		Button(action: action) {
			Text(title)
				.font(.subheadline.weight(.semibold))
				.foregroundStyle(Color.mm_text_primary)
				.lineLimit(1)
				.minimumScaleFactor(0.8)
				.frame(maxWidth: .infinity, minHeight: 50)
				.background(Color.mm_background_secondary, in: Capsule())
		}
		.buttonStyle(.plain)
	}

	// MARK: Действия

	private func tap(_ index: Int) {
		guard self.cells.indices.contains(index), self.cells[index] != 0 else { return }
		if self.selected == nil, InversionMath.neighborsOfBlank(self.cells, size: self.size).contains(index) {
			self.slide(index)
		} else if let selected = self.selected {
			if selected == index {
				self.selected = nil
			} else {
				self.swap(selected, index)
			}
		} else {
			self.selected = index
		}
	}

	/// Ход как в игре: плитка уезжает на место пустой клетки
	private func slide(_ index: Int) {
		guard let blank = self.cells.firstIndex(of: 0) else { return }
		let value = self.cells[index]
		self.apply(text: String(format: "mix.sandbox.log.slide".localized, Int(value))) {
			$0.swapAt(blank, index)
		}
	}

	/// Обмен двух плиток — по правилам игры так нельзя, и чётность меняется
	private func swap(_ first: Int, _ second: Int) {
		let a = self.cells[first]
		let b = self.cells[second]
		self.apply(text: String(format: "mix.sandbox.log.swap".localized, Int(a), Int(b))) {
			$0.swapAt(first, second)
		}
	}

	private func apply(text: String, change: (inout [MatrixElement]) -> Void) {
		let before = InversionMath.count(self.cells, size: self.size) % 2
		var cells = self.cells
		change(&cells)
		let flipped = before != InversionMath.count(cells, size: self.size) % 2
		let result = text + " — " + (flipped ? "mix.sandbox.log.flipped".localized : "mix.sandbox.log.same".localized)
		withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
			self.cells = cells
			self.selected = nil
			self.log = Array(([LogEntry(text: result, flipped: flipped)] + self.log).prefix(3))
		}
	}

	private func setSize(_ size: Int) {
		guard size != self.size else { return }
		withAnimation(.easeInOut(duration: 0.25)) {
			self.size = size
			self.cells = InversionMath.solved(size: size)
			self.selected = nil
			self.log = []
		}
	}
}

/// Область над панелью: переключатель размера и поле
private struct SandboxBoardArea: View {
	let sizes: [Int]
	let size: Int
	let cells: [MatrixElement]
	let selected: Int?
	let showsSnake: Bool
	let onSize: (Int) -> Void
	let onTap: (Int) -> Void

	@Environment(\.settingsHeaderInset) private var headerInset

	var body: some View {
		VStack(spacing: 16) {
			CompactSegmentedPicker(
				items: self.sizes,
				selected: self.size,
				title: { "\($0)×\($0)" },
				onSelect: self.onSize
			)
			.frame(width: 150)
			.accessibilityLabel("mix.manual.size".localized)
			InversionBoardView(
				cells: self.cells,
				size: self.size,
				tileSide: self.size == 3 ? 72 : 56,
				spacing: 8,
				selected: self.selected,
				showsSnake: self.showsSnake,
				onTap: self.onTap
			)
		}
		.padding(.top, self.headerInset + 8)
		.padding(.horizontal, 16)
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
		.background(Color.black)
	}
}

#Preview {
	InversionSandboxView()
}
