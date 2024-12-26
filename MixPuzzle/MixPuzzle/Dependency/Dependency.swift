//
//  Dependency.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 26.04.2024.
//

import MFPuzzle
import Foundation

protocol _Dependency {
	var puzzle: _Puzzle { get }
	var checker: _Checker { get }
	var workers: _Workers { get }
    var settingsStorages: _SettingsStorage { get }
}

struct Dependency: _Dependency {
	let puzzle: _Puzzle
	let checker: _Checker
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
		
		let rotationWorker = RotationWorker()
		let materialsWorker = MaterialsWorker()
		let asteroidworker = AsteroidsWorker(
			rotationWorker: rotationWorker,
			materialsWorker: materialsWorker,
			asteroidsStorage: settingsAsteroidsStorage
		)
		
		let checker = Checker()
		let textNodeWorker = TextNodeWorker()
		self.checker = checker
		self.puzzle = Puzzle(heuristic: .manhattan, checker: checker)
		let imageWorker = ImageWorker()
		let cubeWorker = CubeWorker(imageWorker: imageWorker, materialsWorker: materialsWorker)
		let fileWorker = FileWorker()
		let matrixWorker = MatrixWorker(checker: checker)
		let decoder = Decoder()
		let statisticsWorker = StatisticsWorker(keeper: fileWorker, decoder: decoder)
		let gameWorker = GameWorker(
			checker: checker,
			keeper: fileWorker,
			matrixWorker: matrixWorker,
			statisticsWorker: statisticsWorker,
			settingsGameStorage: settingsGameStorage
		)
		
		self.workers = Workers(
			keeper: fileWorker,
			gameWorker: gameWorker,
			cubeWorker: cubeWorker,
			imageWorker: imageWorker,
			matrixWorker: matrixWorker,
			rotationWorker: rotationWorker,
			textNodeWorker: textNodeWorker,
			asteroidWorker: asteroidworker,
			materialsWorker: materialsWorker
		)
		
    }
}
