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
		let fileForker = FileWorker()
		let gameWorker = GameWorker(fileWorker: fileForker)
		let text = gameWorker.load()
		let matrixSpiral = try? matrixWorker.creationMatrix(text: text)
		let grid = Grid(matrix: matrixSpiral ?? matrixWorker.createMatrixSpiral(size: 4))
		let boxWorker = BoxesWorker(grid: grid, cubeWorker: cubeWorker, gameWorker: gameWorker, settingsCubeStorate: dependency.settingsStorages.settingsCubeStorage, startSceneDependency: startSceneDependency)
		return StartScene(boxWorker: boxWorker, startsWorker: starsWorker, settingsAsteroidsStorage: dependency.settingsStorages.settingsAsteroidsStorage)
	}
}
