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
	let dependency: _Dependency
	let matrixTarger: Matrix
	@State private var compasses: [Compass] = []
	@State private var isLoading = false
	@State private var onClose = false
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		ProgressView("Calculating...")
			.foregroundStyle(Color.mm_divider_opaque)
			.scaleEffect(x: 2, y: 2, anchor: .center)
			.padding()
			.onAppear {
				performCalculation()
			}
			.onChange(of: onClose) { value in
				self.dismiss()
			}
			.fullScreenCover(isPresented: $isLoading) {
				VisualizationSolutionView(matrix: matrix, compasses: compasses, dependency: dependency, onClose: $onClose)
			}
	}
	
	public func performCalculation() {
		Task {
			let board = Board(grid: Grid(matrix: self.matrix))
			let boardTarget = Board(grid: Grid(matrix: self.matrixTarger))
			if let finalBoard = self.dependency.puzzle.searchSolutionWithHeap(board: board, boardTarget: boardTarget) {
				Task { @MainActor in
					self.compasses = self.dependency.puzzle.createPath(board: finalBoard).reversed()
					self.compasses.append(.needle)
					self.isLoading = true
				}
			} else {
				Task { @MainActor in
					self.dismiss()
				}
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
	return LoadingView(matrix: matrix, dependency: dependency, matrixTarger: matrixTarger)
}
