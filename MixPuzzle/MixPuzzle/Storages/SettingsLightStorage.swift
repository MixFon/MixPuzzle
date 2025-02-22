//
//  SettingsLightStorage.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 22.02.2025.
//

import Foundation

protocol _SettingsLightStorage {
	var lightType: LightType { get set }
	var countLights: Int { get set }
	var isMotionEnabled: Bool { get set }
	var isShadowEnabled: Bool { get set }
}

enum LightType: String, CaseIterable, CustomStringConvertible {
	
	/// Свет идет в виде прожектора, в виде конуса
	case spot
	/// Свет идет во все стороны из точки источника
	case omni
	/// Свет идет во все стороны, нет теней
	case ambient
	/// Неопределено
	case undefined
	/// Свет идет по направлению, но не исеет точки источника
	case directional
	
	init(rawValue: String?) {
		switch rawValue {
		case "spot":
			self = .spot
		case "omni":
			self = .omni
		case "ambient":
			self = .ambient
		case "directional":
			self = .directional
		default:
			self = .undefined
		}
	}
	
	var description: String {
		self.rawValue
	}
}

final class SettingsLightStorage: _SettingsLightStorage {
	
	private let defaults = UserDefaults.standard
	
	private enum Keys {
		static let lightType = "settings.light.type"
		static let countLights = "settings.light.count"
		static let isMotionEnabled = "settings.light.motion"
		static let isShadowEnabled = "settings.light.shadow"
	}
	
	init() {
		// Регистрируем значения по умолчанию
		let defaultValues: [String: Any] = [
			Keys.lightType : "omni",
			Keys.countLights : 1,
			Keys.isMotionEnabled : true,
			Keys.isShadowEnabled : true
		]
		self.defaults.register(defaults: defaultValues)
	}
	
	var lightType: LightType {
		get {
			let type = self.defaults.string(forKey: Keys.lightType)
			return LightType(rawValue: type)
		}
		set {
			self.defaults.set(newValue.rawValue, forKey: Keys.lightType)
		}
	}
	
	var countLights: Int {
		get {
			self.defaults.integer(forKey: Keys.countLights)
		}
		set {
			self.defaults.set(newValue, forKey: Keys.countLights)
		}
	}
	
	var isMotionEnabled: Bool {
		get {
			self.defaults.bool(forKey: Keys.isMotionEnabled)
		}
		set {
			self.defaults.set(newValue, forKey: Keys.isMotionEnabled)
		}
	}
	
	var isShadowEnabled: Bool {
		get {
			self.defaults.bool(forKey: Keys.isShadowEnabled)
		}
		set {
			self.defaults.set(newValue, forKey: Keys.isShadowEnabled)
		}
	}
}

final class MockSettingsLightStorage: _SettingsLightStorage {
	var lightType: LightType = .omni
	var countLights: Int = 1
	var isMotionEnabled: Bool = true
	var isShadowEnabled: Bool = true
}
