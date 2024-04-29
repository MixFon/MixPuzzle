//
//  Dependency.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 26.04.2024.
//

import Foundation

protocol _Dependency {
    var settingsStorages: _SettingsStorage { get }
}

struct Dependency: _Dependency {
    let settingsStorages: _SettingsStorage
    
    init() {
        let settingsCubeStorage = SettingsCubeStorage()
        let settingsAsteroidsStorage = SettingsAsteroidsStorage()
        self.settingsStorages = SettingsStorage(settingsCubeStorage: settingsCubeStorage, settingsAsteroidsStorage: settingsAsteroidsStorage)
    }
}
