//
//  SettingsGame.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 09.05.2024.
//

import Foundation

protocol _SettingsGameStorage {
	/// Текуший/выбранный уровень
	var currentLevel: Int { get set }
	/// Доступна ли вибрация
	var isUseVibration: Bool { get set }
	/// Максимально доступный уровень
	var availableLevel: Int { get }
	/// Самый высокий открытый уровень
	var maxAchievedLevel: Int { get set }
}

final class SettingsGameStorage: _SettingsGameStorage {
	
	let availableLevel: Int = 10
	
	private let defaults = UserDefaults.standard
	
	private enum Keys {
		static let currentLevel = "settings.game.level"
		static let isUseVibration = "settings.game.vibration"
		static let maxAchievedLevel = "settings.game.level.achieved"
	}
	
	init() {
		// Регистрируем значения по умолчанию
		let defaultValues: [String: Any] = [
			Keys.currentLevel : 3,
			Keys.isUseVibration : true,
			Keys.maxAchievedLevel : 3
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
	
	var maxAchievedLevel: Int {
		get {
			self.defaults.integer(forKey: Keys.maxAchievedLevel)
		}
		set {
			self.defaults.set(newValue, forKey: Keys.maxAchievedLevel)
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
	var availableLevel: Int = 15
	var currentLevel: Int = 4
	var isUseVibration: Bool = true
	var maxAchievedLevel: Int = 5
}
