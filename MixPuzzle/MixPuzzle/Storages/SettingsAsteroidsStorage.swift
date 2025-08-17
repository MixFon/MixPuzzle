//
//  SettingsAsteroidsStorage.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 29.04.2024.
//

import Foundation

protocol _SettingsAsteroidsStorage {
	/// Радиус сферы астеройдов
    var radiusSphere: Double { get set }
	/// Кодичество астеройдов
    var asteroidsCount: Double { get set }
	/// Показывать ли астеройды
    var isShowAsteroids: Bool { get set }
}

final class SettingsAsteroidsStorage: _SettingsAsteroidsStorage {
    
    private let defaults = NSUbiquitousKeyValueStore.default
    
    private enum Keys {
        static let show = "settings.asteroids.show"
        static let radiusSphere = "settings.asteroids.ratius.sphere"
        static let asteroidsCount = "settings.asteroids.count"
    }
    
    init() { }
    
    var radiusSphere: Double {
        get {
            let radiusSphere = self.defaults.double(forKey: Keys.radiusSphere)
			return radiusSphere == 0 ? 20.0 : radiusSphere
        }
        set {
            self.defaults.set(newValue, forKey: Keys.radiusSphere)
        }
    }
    
    var asteroidsCount: Double {
        get {
            let asteroidsCount = self.defaults.double(forKey: Keys.asteroidsCount)
			return asteroidsCount == 0.0 ? 200.0 : asteroidsCount
        }
        set {
            self.defaults.set(newValue, forKey: Keys.asteroidsCount)
        }
    }
    
    var isShowAsteroids: Bool {
        get {
            let isShow = self.defaults.bool(forKey: Keys.show)
			return !isShow
        }
        set {
            self.defaults.set(!newValue, forKey: Keys.show)
        }
    }
}

