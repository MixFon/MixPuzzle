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
	
	func configure(dependency: SettingsCubeDependency) -> some View {
		let imageWorker = ImageWorker()
        let materialsWorker = MaterialsWorker()
		let cubeWorker = CubeWorker(imageWorker: imageWorker, materialsWorker: materialsWorker)
		return SettingsCubeScene(cubeWorker: cubeWorker, imageWorker: imageWorker, dependency: dependency)
	}
}
