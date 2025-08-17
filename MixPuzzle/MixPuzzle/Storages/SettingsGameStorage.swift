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
	
	private let defaults = NSUbiquitousKeyValueStore.default
	
	private enum Keys {
		static let currentLevel = "settings.game.level"
		static let isUseVibration = "settings.game.vibration"
		static let maxAchievedLevel = "settings.game.level.achieved"
	}
	
	init() { }
	
	var currentLevel: Int {
		get {
			let currentLevel = self.defaults.double(forKey: Keys.currentLevel)
			return currentLevel == 0 ? 3 : Int(currentLevel)
		}
		set {
			self.defaults.set(Double(newValue), forKey: Keys.currentLevel)
		}
	}
	
	var maxAchievedLevel: Int {
		get {
			let maxAchievedLevel = self.defaults.double(forKey: Keys.maxAchievedLevel)
			return maxAchievedLevel == 0 ? 3 : Int(maxAchievedLevel)
		}
		set {
			self.defaults.set(Double(newValue), forKey: Keys.maxAchievedLevel)
		}
	}
	
	var isUseVibration: Bool {
		get {
			let isUseVibration = self.defaults.bool(forKey: Keys.isUseVibration)
			return !isUseVibration
		}
		set {
			self.defaults.set(!newValue, forKey: Keys.isUseVibration)
		}
	}
}

final class MockSettingsGameStorage: _SettingsGameStorage {
	var availableLevel: Int = 15
	var currentLevel: Int = 4
	var isUseVibration: Bool = true
	var maxAchievedLevel: Int = 5
}
