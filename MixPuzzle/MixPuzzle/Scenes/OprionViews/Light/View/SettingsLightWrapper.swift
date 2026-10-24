//
//  SettingsLightWrapper.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 24.10.2026.
//

import SwiftUI
import Foundation

/// Обертка для сцены превью настроек освещения
@MainActor
struct SettingsLightWrapper: View {
	
	let model: SettingsLightModel
	let dependency: _Dependency
	private let factory = SettingsLightFactory()
	
	var body: some View {
		self.factory.configure(model: self.model, dependency: self.dependency)
	}
}

extension SettingsLightWrapper: Equatable {
	nonisolated static func == (lhs: SettingsLightWrapper, rhs: SettingsLightWrapper) -> Bool {
		return true
	}
}
