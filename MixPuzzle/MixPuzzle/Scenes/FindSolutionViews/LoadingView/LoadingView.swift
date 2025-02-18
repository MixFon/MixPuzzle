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
	let puzzle: _Puzzle
	let matrixTarger: Matrix
	let onFinedSolution: ([Compass]) -> Void
	private let limiter: Int = 1000000
	
	@State private var calculationTask: Task<Void, Error>?
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		VStack(spacing: 16) {
			MovingSquaresLoader()
			Button {
				self.calculationTask?.cancel()
				self.dismiss()
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
		let board = Board(grid: Grid(matrix: self.matrix))
		let boardTarget = Board(grid: Grid(matrix: self.matrixTarger))
		if let finalBoard = try await self.puzzle.searchSolutionWithHeap(board: board, limiter: self.limiter, boardTarget: boardTarget) {
			await MainActor.run {
				guard !Task.isCancelled else { return }
				var compasses: [Compass] = puzzle.createPath(board: finalBoard).reversed()
				compasses.append(.needle)
				self.onFinedSolution(compasses)
			}
		} else {
			await MainActor.run {
				guard !Task.isCancelled else { return }
				self.dismiss()
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
