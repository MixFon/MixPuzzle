//
//  SettingsStorage.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 25.04.2024.
//

import SwiftUI
import Foundation

protocol _SettingsStorage {
    var settingsCubeStorage: _SettingsCubeStorage { get }
}

final class SettingsStorage: _SettingsStorage {
    var settingsCubeStorage: _SettingsCubeStorage
   
    init(settingsCubeStorage: _SettingsCubeStorage) {
        self.settingsCubeStorage = settingsCubeStorage
    }
}

protocol _SettingsCubeStorage {
    var sizeImage: Double { get set }
    var colorLable: Color? { get set }
    var radiusImage: Double { get set }
    var radiusChamfer: Double { get set }
    var colorBackground: Color? { get set }
}

final class SettingsCubeStorage: _SettingsCubeStorage {
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let sizeImage = "settings.cube.size.image"
        static let colorLable = "settings.cube.color.lable"
        static let radiusImage = "settings.cube.radius.image"
        static let radiusChamfer = "settings.cube.radius.chamfer"
        static let colorBackground = "settings.cube.color.background"
    }
    
    init() {
        // Регистрируем значения по умолчанию
        let defaultValues: [String: Any] = [
            Keys.sizeImage : 50.0,
            Keys.radiusImage : 10.0,
            Keys.radiusChamfer : 1.0,
            Keys.colorLable : "#007AFF",
            Keys.colorBackground : "#FF3B30",
        ]
        self.defaults.register(defaults: defaultValues)
    }
    
    var sizeImage: Double {
        get {
            self.defaults.double(forKey: Keys.sizeImage)
        }
        set {
            self.defaults.set(newValue, forKey: Keys.sizeImage)
        }
    }
    
    var colorLable: Color? {
        get {
            guard let colorHex = self.defaults.string(forKey: Keys.colorLable) else { return nil }
            return Color(hex: colorHex)
        }
        
        set {
            self.defaults.set(newValue?.toHex(), forKey: Keys.colorLable)
        }
    }
    
    var radiusImage: Double {
        get {
            self.defaults.double(forKey: Keys.radiusImage)
        }
        set {
            self.defaults.set(newValue, forKey: Keys.radiusImage)
        }
    }
    
    var radiusChamfer: Double {
        get {
            self.defaults.double(forKey: Keys.radiusChamfer)
        }
        set {
            self.defaults.set(newValue, forKey: Keys.radiusChamfer)
        }
    }
    
    var colorBackground: Color? {
        get {
            guard let colorHex = self.defaults.string(forKey: Keys.colorBackground) else { return nil }
            return Color(hex: colorHex)
        }
        
        set {
            self.defaults.set(newValue?.toHex(), forKey: Keys.colorBackground)
        }
    }
}
