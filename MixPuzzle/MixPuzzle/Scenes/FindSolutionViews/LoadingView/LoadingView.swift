//
//  LoadingView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 02.06.2024.
//

import SwiftUI
import MFPuzzle

struct LoadingView: View {
	let matrix: Matrix
	@MainActor let puzzle: _Puzzle
	let matrixTarger: Matrix
	let onFinedSolution: ([Compass]?) -> Void
	
	@State private var calculationTask: Task<Void, Error>?
	
	var body: some View {
		VStack(spacing: 16) {
			MovingSquaresLoader()
			Button {
				self.calculationTask?.cancel()
				self.onFinedSolution(nil)
			} label: {
				Image.mix_icon_cancel
					.resizable()
					.frame(width: 64, height: 64)
			}
		}
		.onAppear {
			self.calculationTask = Task {
				try await performCalculation()
			}
		}
		.onDisappear {
			self.calculationTask?.cancel()
		}
	}
	
	public func performCalculation() async throws {
		// Копируем данные, чтобы избежать доступа к MainActor-изолированным свойствам
		//let board =
		let limiter = 1000000 // Копируем limiter
		let puzzle: _Puzzle = self.puzzle

		// Выполняем в Task.detached, избегая прямого доступа к puzzle
		let finalBoard = try await Task.detached {
			// Предполагаем, что searchSolutionWithHeap можно вызвать в неизолированном контексте
			return try await puzzle.searchSolutionWithHeap(board: Board(grid: Grid<MatrixElement>(matrix: self.matrix, zero: 0)), limiter: limiter, boardTarget: Board(grid: Grid<MatrixElement>(matrix: self.matrixTarger, zero: 0)))
		}.value

		// Обновляем UI на MainActor
		await MainActor.run {
			guard !Task.isCancelled else { return }
			if let finalBoard = finalBoard {
				var compasses: [Compass] = puzzle.createPath(board: finalBoard).reversed()
				compasses.append(.needle)
				self.onFinedSolution(compasses)
			} else {
				self.onFinedSolution(nil)
			}
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
