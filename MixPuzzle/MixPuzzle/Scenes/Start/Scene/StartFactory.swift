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
			settingsCubeStorate: dependency.settingsStorages.settingsCubeStorage
		)
		let startScene = StartScene(
			boxWorker: boxWorker,
			gameWorker: dependency.workers.gameWorker,
			asteroidWorker: dependency.workers.asteroidWorker,
			startSceneModel: startSceneModel,
			settingsAsteroidsStorage: dependency.settingsStorages.settingsAsteroidsStorage
		)
		return startScene
	}
}
