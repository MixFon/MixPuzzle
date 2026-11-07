//
//  LoadingView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 02.06.2024.
//

import SwiftUI
import MFPuzzle

/// Экран поиска решения: «живые пятнашки» в стеклянной карточке, время поиска,
/// сменяющиеся подсказки и кнопка отмены.
struct LoadingView: View {
	let matrix: Matrix
	let puzzle: _Puzzle
	let matrixTarger: Matrix
	/// Вызывается, если решение не найдено (исчерпан лимит шагов или ошибка), но не при отмене
	var onNotFound: () -> Void = {}
	let onFinedSolution: ([Compass]?) -> Void

	@State private var calculationTask: Task<Void, Never>?
	@State private var startDate = Date()

	/// Сколько секунд показывается одна подсказка
	private let tipDuration = 4
	private let tips = [
		"mix.loading.tip.shortest".localized,
		"mix.loading.tip.distance".localized,
		"mix.loading.tip.cancel".localized,
	]

	var body: some View {
		VStack(spacing: 0) {
			Text("mix.loading.title".localized)
				.font(.headline)
				.foregroundStyle(Color.mm_text_primary)
				.padding(.horizontal, 16)
				.frame(height: 36)
				.glassBackground(in: Capsule())
				.padding(.top, 8)
				.accessibilityAddTraits(.isHeader)
			Spacer(minLength: 24)
			TimelineView(.periodic(from: self.startDate, by: 1)) { context in
				let elapsed = max(0, Int(context.date.timeIntervalSince(self.startDate)))
				VStack(spacing: 32) {
					VStack(spacing: 22) {
						// Расстановка пользователя в её размере, плитки двигаются случайно
						SlidingTilesLoader(matrix: self.matrix)
						Text(String(format: "mix.loading.status".localized, Self.format(elapsed)))
							.font(.headline)
							.monospacedDigit()
							.foregroundStyle(Color.mm_text_primary)
					}
					.padding(26)
					.glassBackground(in: RoundedRectangle(cornerRadius: 32, style: .continuous))
					self.tipView(index: (elapsed / self.tipDuration) % self.tips.count)
				}
			}
			Spacer(minLength: 24)
			Button {
				self.calculationTask?.cancel()
				self.onFinedSolution(nil)
			} label: {
				Text("mix.loading.cancel".localized)
					.font(.body.weight(.semibold))
					.foregroundStyle(Color.mm_text_primary)
					.frame(maxWidth: .infinity, minHeight: 54)
					.glassBackground(in: Capsule())
			}
			.buttonStyle(.plain)
			.padding(.bottom, 16)
		}
		.padding(.horizontal, 24)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color.black.ignoresSafeArea())
		.onAppear {
			self.startDate = Date()
			self.calculationTask = Task {
				await self.performCalculation()
			}
		}
		.onDisappear {
			self.calculationTask?.cancel()
		}
	}

	/// Подсказка и точки-индикаторы под ней
	private func tipView(index: Int) -> some View {
		VStack(spacing: 10) {
			Text(self.tips[index])
				.font(.subheadline)
				.foregroundStyle(Color.mm_text_secondary)
				.multilineTextAlignment(.center)
				.fixedSize(horizontal: false, vertical: true)
				.frame(minHeight: 40, alignment: .top)
				.id(index)
				.transition(.opacity)
			HStack(spacing: 6) {
				ForEach(self.tips.indices, id: \.self) { dot in
					Circle()
						.fill(dot == index ? Color.mm_tint_secondary : Color.mm_text_secondary.opacity(0.4))
						.frame(width: 6, height: 6)
				}
			}
			.accessibilityHidden(true)
		}
		.padding(.horizontal, 8)
		.animation(.easeInOut(duration: 0.4), value: index)
	}

	/// 0:07, 1:23
	private static func format(_ seconds: Int) -> String {
		String(format: "%d:%02d", seconds / 60, seconds % 60)
	}

	private func performCalculation() async {
		let limiter = 1000000
		do {
			let finalBoard = try await self.puzzle.searchSolutionWithHeap(
				board: Board(grid: Grid<MatrixElement>(matrix: self.matrix, zero: 0)),
				limiter: limiter,
				boardTarget: Board(grid: Grid<MatrixElement>(matrix: self.matrixTarger, zero: 0))
			)
			guard !Task.isCancelled else { return }
			if let finalBoard {
				var compasses: [Compass] = self.puzzle.createPath(board: finalBoard).reversed()
				compasses.append(.needle)
				self.onFinedSolution(compasses)
			} else {
				// Лимит шагов исчерпан: сообщаем об этом, а не закрываем экран молча
				self.onNotFound()
				self.onFinedSolution(nil)
			}
		} catch {
			guard !Task.isCancelled, !(error is CancellationError) else { return }
			self.onNotFound()
			self.onFinedSolution(nil)
		}
	}
}

#Preview {
	let matrix: Matrix =
	[[1, 2, 3],
	 [4, 5, 6],
	 [7, 0, 8]]
	let matrixTarger: Matrix =
	[[1, 2, 3],
	 [4, 5, 6],
	 [7, 8, 0]]
	let dependency = MockDependency()
	let puzzle = dependency.createPuzzle()
	return LoadingView(matrix: matrix, puzzle: puzzle, matrixTarger: matrixTarger, onFinedSolution: { _ in })
}
