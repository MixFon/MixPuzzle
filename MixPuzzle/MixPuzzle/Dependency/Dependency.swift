//
//  Dependency.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 26.04.2024.
//

import MFPuzzle
import Foundation

protocol _Dependency {
	var workers: _Workers { get }
    var settingsStorages: _SettingsStorage { get }
}

struct Dependency: _Dependency {
	let workers: _Workers
    let settingsStorages: _SettingsStorage
    
    init() {
        let settingsCubeStorage = SettingsCubeStorage()
        let settingsAsteroidsStorage = SettingsAsteroidsStorage()
		let settingsGameStorage = SettingsGameStorage()
        self.settingsStorages = SettingsStorage(
			settingsCubeStorage: settingsCubeStorage,
			settingsGameStorage: settingsGameStorage,
			settingsAsteroidsStorage: settingsAsteroidsStorage
		)
		
		let materialsWorker = MaterialsWorker()
		let asteroidworker = AsteroidsWorker(materialsWorker: materialsWorker, asteroidsStorage: settingsAsteroidsStorage)
		
		let checker = Checker()
		let imageWorker = ImageWorker()
		let cubeWorker = CubeWorker(imageWorker: imageWorker, materialsWorker: materialsWorker)
		let fileForker = FileWorker()
		let matrixWorker = MatrixWorker()
		let gameWorker = GameWorker(
			checker: checker,
			fileWorker: fileForker,
			matrixWorker: matrixWorker,
			settingsGameStorage: settingsGameStorage
		)
		
		self.workers = Workers(
			fileWorker: fileForker,
			gameWorker: gameWorker,
			cubeWorker: cubeWorker,
			imageWorker: imageWorker,
			matrixWorker: matrixWorker,
			asteroidWorker: asteroidworker,
			materialsWorker: materialsWorker
		)
		
    }
}
