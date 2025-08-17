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

enum LightType: String, CustomStringConvertible {
	
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
	
	static var allCases: [LightType] {
		[.spot, .omni, .ambient, .directional]
	}
}

final class SettingsLightStorage: _SettingsLightStorage {
	
	private let defaults = NSUbiquitousKeyValueStore.default
	
	private enum Keys {
		static let lightType = "settings.light.type"
		static let countLights = "settings.light.count"
		static let isMotionEnabled = "settings.light.motion"
		static let isShadowEnabled = "settings.light.shadow"
	}
	
	init() { }
	
	var lightType: LightType {
		get {
			let type = self.defaults.string(forKey: Keys.lightType) ?? "directional"
			return LightType(rawValue: type)
		}
		set {
			self.defaults.set(newValue.rawValue, forKey: Keys.lightType)
		}
	}
	
	var countLights: Int {
		get {
			let countLights = self.defaults.double(forKey: Keys.countLights)
			return countLights == 0.0 ? 1 : Int(countLights)
		}
		set {
			self.defaults.set(newValue, forKey: Keys.countLights)
		}
	}
	
	var isMotionEnabled: Bool {
		get {
			let isMotionEnabled = self.defaults.bool(forKey: Keys.isMotionEnabled)
			return !isMotionEnabled
		}
		set {
			self.defaults.set(!newValue, forKey: Keys.isMotionEnabled)
		}
	}
	
	var isShadowEnabled: Bool {
		get {
			let isShadowEnabled = self.defaults.bool(forKey: Keys.isShadowEnabled)
			return !isShadowEnabled
		}
		set {
			self.defaults.set(!newValue, forKey: Keys.isShadowEnabled)
		}
	}
}

final class MockSettingsLightStorage: _SettingsLightStorage {
	var lightType: LightType = .omni
	var countLights: Int = 1
	var isMotionEnabled: Bool = true
	var isShadowEnabled: Bool = true
}
