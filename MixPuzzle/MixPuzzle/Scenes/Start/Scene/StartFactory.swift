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
		// Занимается созданием и управлением звездочек
		let starsWorker = StarsWorker()
		
		// Занимается созданием и управление кубиков
		let imageWorker = ImageWorker()
		let cubeWorker = CubeWorker(imageWorker: imageWorker)
		let matrixWorker = MatrixWorker()
		let matrixSpiral = matrixWorker.createMatrixSpiral(size: 4)
		let grid = Grid(matrix: matrixSpiral)
		let boxWorker = BoxesWorker(grid: grid, cubeWorker: cubeWorker)
		return StartScene(boxWorker: boxWorker, startsWorker: starsWorker, complition: complition)
	}
}
