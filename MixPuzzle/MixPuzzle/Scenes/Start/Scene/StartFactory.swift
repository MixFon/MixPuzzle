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
	
	func configure(dependency: _Dependency, startSceneModel: StartSceneModel) -> some View {
		
		let text = dependency.workers.gameWorker.load()
		let matrixWorker = MatrixWorker()
		let matrixSpiral = try? matrixWorker.creationMatrix(text: text)
		let grid = Grid(matrix: matrixSpiral ?? matrixWorker.createMatrixSpiral(size: 4))
		let boxWorker = BoxesWorker(
			grid: grid,
			cubeWorker: dependency.workers.cubeWorker,
			gameWorker: dependency.workers.gameWorker,
			settingsCubeStorate: dependency.settingsStorages.settingsCubeStorage,
			startSceneModel: startSceneModel
		)
		let startScene = StartScene(
			boxWorker: boxWorker,
			asteroidWorker: dependency.workers.asteroidWorker,
			settingsAsteroidsStorage: dependency.settingsStorages.settingsAsteroidsStorage
		)
		return startScene
	}
}
