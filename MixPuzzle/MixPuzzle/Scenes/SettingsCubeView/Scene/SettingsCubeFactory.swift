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
	
	func configure() -> some View {
		let boxWorker = BoxesWorker()
		return SettingsCubeScene(boxWorker: boxWorker)
	}
}
