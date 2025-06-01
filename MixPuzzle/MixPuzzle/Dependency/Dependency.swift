//
//  Dependency.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 26.04.2024.
//

import MFPuzzle
import Foundation

@MainActor
protocol _Dependency {
	var checker: _Checker { get }
	var workers: _Workers { get }
    var settingsStorages: _SettingsStorage { get }
	
	func createPuzzle() -> _Puzzle
}

struct Dependency: _Dependency {
	
	let checker: _Checker
	let workers: _Workers
    let settingsStorages: _SettingsStorage
    
    init() {
        let settingsCubeStorage = SettingsCubeStorage()
		let settingsGameStorage = SettingsGameStorage()
		let settingsLightStorage = SettingsLightStorage()
		let settingsAsteroidsStorage = SettingsAsteroidsStorage()
        self.settingsStorages = SettingsStorage(
			settingsCubeStorage: settingsCubeStorage,
			settingsGameStorage: settingsGameStorage,
			settingsLightStorage: settingsLightStorage,
			settingsAsteroidsStorage: settingsAsteroidsStorage
		)
		
		let rotationWorker = RotationWorker()
		let materialsWorker = MaterialsWorker()
		let asteroidworker = AsteroidsWorker(
			rotationWorker: rotationWorker,
			materialsWorker: materialsWorker,
			asteroidsStorage: settingsAsteroidsStorage
		)
		
		let textNodeWorker = TextNodeWorker(materialsWorker: materialsWorker)
		let imageWorker = ImageWorker()
		let cubeWorker = CubeWorker(imageWorker: imageWorker, materialsWorker: materialsWorker)
		let fileWorker = FileWorker()
		let transporter = Transporter()
		let cheker = Checker()
		let matrixWorker = MatrixWorker()
		let decoder = Decoder()
		self.checker = cheker
		let statisticsWorker = StatisticsWorker(keeper: fileWorker, decoder: decoder)
		let lightsWorker = LightsWorker(rotationWorker: rotationWorker, settingsLightStorage: settingsLightStorage)
		let gameWorker = GameWorker(
			keeper: fileWorker,
			checker: cheker,
			matrixWorker: matrixWorker,
			statisticsWorker: statisticsWorker,
			settingsGameStorage: settingsGameStorage
		)
		
		self.workers = Workers(
			keeper: fileWorker,
			gameWorker: gameWorker,
			cubeWorker: cubeWorker,
			transporter: transporter,
			imageWorker: imageWorker,
			lightsWorker: lightsWorker,
			matrixWorker: matrixWorker,
			rotationWorker: rotationWorker,
			textNodeWorker: textNodeWorker,
			asteroidWorker: asteroidworker,
			materialsWorker: materialsWorker
		)
    }
	
	func createPuzzle() -> any _Puzzle {
		return Puzzle(heuristic: .manhattan)
	}
}
