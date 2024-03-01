//
//  StartFactory.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 01.03.2024.
//

import SwiftUI
import MFPuzzle
import Foundation

final class StartFactory {
	
	func configure(complition: @escaping (MenuView.Router) -> ()) -> some View {
		// Занимается созданием
		let matrixWorker = MatrixWorker()
		let matrixSpiral = matrixWorker.createMatrixSpiral(size: 4)
		let grid = Grid(matrix: matrixSpiral)
		let boxWorker = BoxesWorker(grid: grid)
		return StartScene(worker: boxWorker, complition: complition)
	}
}
