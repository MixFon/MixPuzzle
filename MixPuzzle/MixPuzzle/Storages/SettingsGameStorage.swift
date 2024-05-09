//
//  SettingsGame.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 09.05.2024.
//

import Foundation

protocol _SettingsGameStorage {
	var currentLevel: Int { get set }
}

final class SettingsGameStorage: _SettingsGameStorage {
	private let defaults = UserDefaults.standard
	
	private enum Keys {
		static let currentLevel = "settings.game.level"
	}
	
	init() {
		// Регистрируем значения по умолчанию
		let defaultValues: [String: Any] = [
			Keys.currentLevel : 3
		]
		self.defaults.register(defaults: defaultValues)
	}
	
	var currentLevel: Int {
		get {
			self.defaults.integer(forKey: Keys.currentLevel)
		}
		set {
			self.defaults.set(newValue, forKey: Keys.currentLevel)
		}
	}
}

final class MockSettingsGameStorage: _SettingsGameStorage {
	var currentLevel: Int = 4
}
