//
//  SettingsCube.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 29.04.2024.
//

import SwiftUI
import Foundation

protocol _SettingsCubeStorage {
    var texture: String? { get set }
    var sizeImage: Double { get set }
    var colorLable: Color? { get set }
    var radiusImage: Double { get set }
    var radiusChamfer: Double { get set }
}

final class SettingsCubeStorage: _SettingsCubeStorage {
    
    private let defaults = NSUbiquitousKeyValueStore.default
    
    private enum Keys {
        static let texture = "settings.cube.texture"
        static let sizeImage = "settings.cube.size.image"
        static let colorLable = "settings.cube.color.lable"
        static let radiusImage = "settings.cube.radius.image"
        static let radiusChamfer = "settings.cube.radius.chamfer"
    }
    
    init() { }
    
    var sizeImage: Double {
        get {
            let sizeImage = self.defaults.double(forKey: Keys.sizeImage)
			return sizeImage == 0 ? 200 : sizeImage
        }
        set {
            self.defaults.set(newValue, forKey: Keys.sizeImage)
        }
    }
    
    var colorLable: Color? {
        get {
            let colorHex = self.defaults.string(forKey: Keys.colorLable) ?? "#007AFF"
            return Color(hex: colorHex)
        }
        set {
            self.defaults.set(newValue?.toHex(), forKey: Keys.colorLable)
        }
    }
    
    var radiusImage: Double {
        get {
			let radiusImage = self.defaults.double(forKey: Keys.radiusImage)
			return radiusImage == 0 ? 50 : radiusImage
        }
        set {
            self.defaults.set(newValue, forKey: Keys.radiusImage)
        }
    }
    
    var radiusChamfer: Double {
        get {
            let radius = self.defaults.double(forKey: Keys.radiusChamfer)
			return radius == 0.0 ? 1.0 : radius
        }
        set {
            self.defaults.set(newValue, forKey: Keys.radiusChamfer)
        }
    }
    
    var texture: String? {
        get {
            self.defaults.string(forKey: Keys.texture) ?? "TerrazzoSlab018"
        }
        set {
            self.defaults.set(newValue, forKey: Keys.texture)
        }
    }
}
