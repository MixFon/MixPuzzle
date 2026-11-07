//
//  LoaderView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 02.06.2024.
//

import SwiftUI
import MFPuzzle

/// Лоадер «живые пятнашки»: показывает расстановку пользователя в её размере,
/// и плитки сами передвигаются случайными ходами (без возврата на только что покинутую клетку).
struct SlidingTilesLoader: View {
	/// Сторона всего поля. Плитки уменьшаются, чтобы поле 5×5 занимало столько же места, сколько 3×3.
	var boardSide: CGFloat = 224
	var spacing: CGFloat = 8

	private let gridSize: Int
	/// cells[i] — номер плитки в клетке i, 0 — пустая
	@State private var cells: [MatrixElement]
	/// Клетка, откуда только что ушла пустота: туда не возвращаемся, чтобы плитки не дёргались туда-обратно
	@State private var previousEmpty: Int?

	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	/// - Parameter matrix: стартовая расстановка (квадратная, с одной пустой клеткой 0)
	init(matrix: Matrix, boardSide: CGFloat = 224, spacing: CGFloat = 8) {
		let size = matrix.count
		let cells = matrix.flatMap { $0 }
		// Защита от некорректной матрицы: показываем решённое поле 3×3
		if size > 1, cells.count == size * size, cells.contains(0) {
			self.gridSize = size
			self._cells = State(initialValue: cells)
		} else {
			self.gridSize = 3
			self._cells = State(initialValue: [1, 2, 3, 4, 5, 6, 7, 8, 0])
		}
		self.boardSide = boardSide
		self.spacing = spacing
	}

	var body: some View {
		let count = CGFloat(self.gridSize)
		let tileSide = (self.boardSide - self.spacing * (count - 1)) / count
		let step = tileSide + self.spacing
		ZStack(alignment: .topLeading) {
			ForEach(self.cells.filter { $0 != 0 }.sorted(), id: \.self) { number in
				let index = self.cells.firstIndex(of: number) ?? 0
				FillingTileView(value: number, side: tileSide, size: self.gridSize, outline: nil)
					.offset(
						x: CGFloat(index % self.gridSize) * step,
						y: CGFloat(index / self.gridSize) * step
					)
			}
		}
		.frame(width: self.boardSide, height: self.boardSide, alignment: .topLeading)
		.accessibilityHidden(true)
		.task {
			await self.animate()
		}
	}

	private func animate() async {
		while !Task.isCancelled {
			// С «уменьшением движения» ходы реже и без пружины
			try? await Task.sleep(nanoseconds: self.reduceMotion ? 1_200_000_000 : 520_000_000)
			guard !Task.isCancelled else { break }
			withAnimation(self.reduceMotion ? .easeInOut(duration: 0.3) : .spring(response: 0.38, dampingFraction: 0.68)) {
				self.makeRandomMove()
			}
		}
	}

	private func makeRandomMove() {
		guard let empty = self.cells.firstIndex(of: 0) else { return }
		let row = empty / self.gridSize
		let column = empty % self.gridSize
		var neighbors: [Int] = []
		if row > 0 { neighbors.append(empty - self.gridSize) }
		if row < self.gridSize - 1 { neighbors.append(empty + self.gridSize) }
		if column > 0 { neighbors.append(empty - 1) }
		if column < self.gridSize - 1 { neighbors.append(empty + 1) }
		let choices = neighbors.filter { $0 != self.previousEmpty }
		guard let pick = choices.randomElement() ?? neighbors.randomElement() else { return }
		self.cells.swapAt(empty, pick)
		self.previousEmpty = empty
	}
}

#Preview {
	VStack(spacing: 24) {
		SlidingTilesLoader(matrix: [[1, 2, 3], [4, 0, 5], [7, 8, 6]])
		SlidingTilesLoader(matrix: [[5, 1, 3, 4], [2, 6, 11, 8], [9, 10, 7, 12], [15, 13, 14, 0]])
	}
	.padding(26)
	.glassBackground(in: RoundedRectangle(cornerRadius: 32, style: .continuous))
	.frame(maxWidth: .infinity, maxHeight: .infinity)
	.background(Color.black)
}
