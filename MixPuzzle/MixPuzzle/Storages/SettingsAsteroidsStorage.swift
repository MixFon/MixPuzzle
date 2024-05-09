//
//  SettingsAsteroidsStorage.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 29.04.2024.
//

import Foundation

protocol _SettingsAsteroidsStorage {
    var radiusSphere: Double { get set }
    var asteroidsCount: Double { get set }
    var isShowAsteroids: Bool { get set }
}

final class SettingsAsteroidsStorage: _SettingsAsteroidsStorage {
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let show = "settings.asteroids.show"
        static let radiusSphere = "settings.asteroids.ratius.sphere"
        static let asteroidsCount = "settings.asteroids.count"
    }
    
    init() {
        // Регистрируем значения по умолчанию
        let defaultValues: [String: Any] = [
            Keys.show : true,
            Keys.radiusSphere : 20,
            Keys.asteroidsCount : 200,
        ]
        self.defaults.register(defaults: defaultValues)
    }
    
    var radiusSphere: Double {
        get {
            self.defaults.double(forKey: Keys.radiusSphere)
        }
        set {
            self.defaults.set(newValue, forKey: Keys.radiusSphere)
        }
    }
    
    var asteroidsCount: Double {
        get {
            self.defaults.double(forKey: Keys.asteroidsCount)
        }
        set {
            self.defaults.set(newValue, forKey: Keys.asteroidsCount)
        }
    }
    
    var isShowAsteroids: Bool {
        get {
            self.defaults.bool(forKey: Keys.show)
        }
        set {
            self.defaults.set(newValue, forKey: Keys.show)
        }
    }
}

