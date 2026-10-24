//
//  SettingsAsteroidsWrapper.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 24.10.2026.
//

import SwiftUI
import Foundation

/// Обертка для сцены превью настроек астероидов
@MainActor
struct SettingsAsteroidsWrapper: View {
	
	let model: SettingsAsteroidsModel
	let dependency: _Dependency
	private let factory = SettingsAsteroidsFactory()
	
	var body: some View {
		self.factory.configure(model: self.model, dependency: self.dependency)
	}
}

extension SettingsAsteroidsWrapper: Equatable {
	nonisolated static func == (lhs: SettingsAsteroidsWrapper, rhs: SettingsAsteroidsWrapper) -> Bool {
		return true
	}
}
