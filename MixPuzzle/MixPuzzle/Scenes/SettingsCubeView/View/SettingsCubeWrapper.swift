//
//  SettingsCubeWrapper.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 12.04.2024.
//

import SwiftUI
import Foundation

struct SettingsCubeWrapper: View {
	
	let dependency: SettingsCubeDependency
	private let factory = SettingsCubeFactory()
	
	var body: some View {
		self.factory.configure(dependency: self.dependency)
	}
}

extension SettingsCubeWrapper: Equatable {
	static func == (lhs: SettingsCubeWrapper, rhs: SettingsCubeWrapper) -> Bool {
		return true
	}
}
