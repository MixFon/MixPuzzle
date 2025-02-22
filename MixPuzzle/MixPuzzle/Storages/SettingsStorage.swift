//
//  SettingsStorage.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 25.04.2024.
//

import SwiftUI
import Foundation

protocol _SettingsStorage {
	var settingsGameStorage: _SettingsGameStorage { get }
    var settingsCubeStorage: _SettingsCubeStorage { get }
	var settingsLightStorage: _SettingsLightStorage { get }
    var settingsAsteroidsStorage: _SettingsAsteroidsStorage { get }
}

final class SettingsStorage: _SettingsStorage {
	var settingsGameStorage: _SettingsGameStorage
    var settingsCubeStorage: _SettingsCubeStorage
	var settingsLightStorage: _SettingsLightStorage
    var settingsAsteroidsStorage: _SettingsAsteroidsStorage
   
    init(settingsCubeStorage: _SettingsCubeStorage, settingsGameStorage: _SettingsGameStorage, settingsLightStorage: _SettingsLightStorage, settingsAsteroidsStorage: _SettingsAsteroidsStorage) {
        self.settingsCubeStorage = settingsCubeStorage
		self.settingsGameStorage = settingsGameStorage
		self.settingsLightStorage = settingsLightStorage
        self.settingsAsteroidsStorage = settingsAsteroidsStorage
    }
}
