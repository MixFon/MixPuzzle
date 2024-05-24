//
//  SettingsGame.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 09.05.2024.
//

import Foundation

protocol _SettingsGameStorage {
	var currentLevel: Int { get set }
	var isUseVibration: Bool { get set }
}

final class SettingsGameStorage: _SettingsGameStorage {
	private let defaults = UserDefaults.standard
	
	private enum Keys {
		static let currentLevel = "settings.game.level"
		static let isUseVibration = "settings.game.vibration"
	}
	
	init() {
		// Регистрируем значения по умолчанию
		let defaultValues: [String: Any] = [
			Keys.currentLevel : 3,
			Keys.isUseVibration : true
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
	
	var isUseVibration: Bool {
		get {
			self.defaults.bool(forKey: Keys.isUseVibration)
		}
		set {
			self.defaults.set(newValue, forKey: Keys.isUseVibration)
		}
	}
}

final class MockSettingsGameStorage: _SettingsGameStorage {
	var currentLevel: Int = 4
	var isUseVibration: Bool = true
}
