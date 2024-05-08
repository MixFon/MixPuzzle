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
		
		let matrix = dependency.workers.gameWorker.matrix
		let grid = Grid(matrix: matrix)
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
