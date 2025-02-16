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
	private let limiter: Int = 1000000
	@ObservedObject private var startSceneModel = StartSceneModel()
	@State private var isLoading = false
	@State private var onClose = false
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		VStack(spacing: 16) {
			MovingSquaresLoader()
			Button {
				self.dismiss()
			} label: {
				Image.mix_icon_cancel
					.resizable()
					.frame(width: 64, height: 64)
			}
		}
		.task {
			await performCalculation()
		}
		.onChange(of: onClose) { value in
			self.dismiss()
		}
		.fullScreenCover(isPresented: $isLoading) {
			VisualizationSolutionView(matrix: matrix, onClose: $onClose, dependency: dependency, startSceneModel: self.startSceneModel)
		}
	}
	
	public func performCalculation() async {
		let board = Board(grid: Grid(matrix: self.matrix))
		let boardTarget = Board(grid: Grid(matrix: self.matrixTarger))
		let puzzle = self.dependency.createPuzzle()
		if let finalBoard = puzzle.searchSolutionWithHeap(board: board, limiter: self.limiter, boardTarget: boardTarget) {
//			Task { @MainActor in
//				var compasses: [Compass] = puzzle.createPath(board: finalBoard).reversed()
//				compasses.append(.needle)
//				self.startSceneModel.compasses = compasses
//				self.isLoading = true
//			}
		} else {
//			Task { @MainActor in
//				self.dismiss()
//			}
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
