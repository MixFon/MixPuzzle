//
//  SettingsCubeFactory.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 12.04.2024.
//

import SwiftUI
import MFPuzzle
import Foundation

final class SettingsCubeFactory {
	
	func configure(model: SettingsCubeModel, depndecy: _Dependency) -> some View {
		let settingsCubeScene = SettingsCubeScene(
			model: model,
			cubeWorker: depndecy.workers.cubeWorker,
			imageWorker: depndecy.workers.imageWorker
		)
		return settingsCubeScene
	}
}
