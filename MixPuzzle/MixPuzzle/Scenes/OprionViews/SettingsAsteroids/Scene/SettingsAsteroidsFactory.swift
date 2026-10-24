//
//  SettingsAsteroidsFactory.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 24.10.2026.
//

import SwiftUI
import MFPuzzle
import Foundation

@MainActor
final class SettingsAsteroidsFactory {
	
	func configure(model: SettingsAsteroidsModel, dependency: _Dependency) -> some View {
		let boxesWorker = BoxesWorker(
			grid: Grid<MatrixElement>(matrix: dependency.workers.gameWorker.previewMatrix, zero: 0),
			cubeWorker: dependency.workers.cubeWorker,
			transporter: dependency.workers.transporter,
			settingsCubeStorate: dependency.settingsStorages.settingsCubeStorage
		)
		let lightsWorker = LightsWorker(
			rotationWorker: dependency.workers.rotationWorker,
			settingsLightStorage: dependency.settingsStorages.settingsLightStorage
		)
		// Отдельный экземпляр, чтобы превью не трогало астероиды игровой сцены
		let asteroidsWorker = AsteroidsWorker(
			rotationWorker: dependency.workers.rotationWorker,
			materialsWorker: dependency.workers.materialsWorker,
			asteroidsStorage: dependency.settingsStorages.settingsAsteroidsStorage
		)
		return SettingsAsteroidsScene(
			model: model,
			boxesWorker: boxesWorker,
			lightsWorker: lightsWorker,
			asteroidsWorker: asteroidsWorker
		)
	}
}
