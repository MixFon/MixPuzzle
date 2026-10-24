//
//  SettingsLightFactory.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 24.10.2026.
//

import SwiftUI
import MFPuzzle
import Foundation

@MainActor
final class SettingsLightFactory {
	
	func configure(model: SettingsLightModel, dependency: _Dependency) -> some View {
		let boxesWorker = BoxesWorker(
			grid: Grid<MatrixElement>(matrix: dependency.workers.gameWorker.previewMatrix, zero: 0),
			cubeWorker: dependency.workers.cubeWorker,
			transporter: dependency.workers.transporter,
			settingsCubeStorate: dependency.settingsStorages.settingsCubeStorage
		)
		// Отдельный экземпляр: он запоминает свои источники, чтобы удалять их при изменении настроек
		let lightsWorker = LightsWorker(
			rotationWorker: dependency.workers.rotationWorker,
			settingsLightStorage: dependency.settingsStorages.settingsLightStorage
		)
		return SettingsLightScene(
			model: model,
			boxesWorker: boxesWorker,
			lightsWorker: lightsWorker
		)
	}
}
