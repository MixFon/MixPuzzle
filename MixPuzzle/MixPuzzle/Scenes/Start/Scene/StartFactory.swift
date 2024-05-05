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
	
	func configure(dependency: _Dependency, startSceneDependency: StartSceneDependency) -> some View {
		// Занимается созданием и управлением звездочек
        let materialsWorker = MaterialsWorker()
        let starsWorker = AsteroidsWorker(materialsWorker: materialsWorker, asteroidsStorage: dependency.settingsStorages.settingsAsteroidsStorage)
        
        // Занимается созданием и управление кубиков
        let imageWorker = ImageWorker()
		let cubeWorker = CubeWorker(imageWorker: imageWorker, materialsWorker: materialsWorker)
		let matrixWorker = MatrixWorker()
		let string = """
4
0 1 2 3
4 5 6 7
8 9 10 11
12 13 14 15
"""
		//let matrixSpiral = matrixWorker.createMatrixSpiral(size: 4)
		let matrixSpiral = try! matrixWorker.creationMatrix(text: string)
		let grid = Grid(matrix: matrixSpiral)
        let boxWorker = BoxesWorker(grid: grid, cubeWorker: cubeWorker, settingsCubeStorate: dependency.settingsStorages.settingsCubeStorage)
		return StartScene(boxWorker: boxWorker, startsWorker: starsWorker, startSceneDependency: startSceneDependency, settingsAsteroidsStorage: dependency.settingsStorages.settingsAsteroidsStorage)
	}
}
