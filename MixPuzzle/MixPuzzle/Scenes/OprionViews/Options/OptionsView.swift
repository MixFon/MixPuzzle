//
//  OptionsView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 24.02.2024.
//

import SwiftUI

final class OptionsViewRouter: ObservableObject {
	@Published var toBox: Bool = false
	@Published var toStars: Bool = false
	@Published var toLanguage: Bool = false
	@Published var toLevelSelect: Bool = false
	@Published var toTargetSelect: Bool = false
}

final class OptionsViewModel: ObservableObject {
	
	@Published var isUseVibration: Bool {
		didSet {
			self.settingsGameStorage.isUseVibration = self.isUseVibration
		}
	}
	
	private var settingsGameStorage: _SettingsGameStorage
	
	init(settingsGameStorage: _SettingsGameStorage) {
		self.settingsGameStorage = settingsGameStorage
		self.isUseVibration = settingsGameStorage.isUseVibration
	}
}

struct OptionsView: View {
    
	private let dependency: _Dependency
	
	@ObservedObject private var model: OptionsViewModel
	@ObservedObject private var router = OptionsViewRouter()
	
	init(dependency: _Dependency) {
		self.dependency = dependency
		self.model = OptionsViewModel(settingsGameStorage: dependency.settingsStorages.settingsGameStorage)
	}
	
	var body: some View {
		VStack {
			NavigationBar(title: "Options")
				.padding()
			ScrollView {
				OptionsSectionsView(title: "Garaphics", cells: [
					AnyView(CellView(icon: "cube", text: "Cube", action: { self.router.toBox = true })),
					AnyView(CellView(icon: "moon.stars", text: "Asteroids", action: { self.router.toStars = true })),
				])
				.padding()
				OptionsSectionsView(title: "Application", cells: [
					AnyView(CellView(icon: "globe", text: "Language", action: { self.router.toLanguage = true })),
					AnyView(ToggleCellView(icon: "waveform.path", text: "Vibration", isOn: self.$model.isUseVibration)),
				])
				.padding()
				OptionsSectionsView(title: "Game", cells: [
					AnyView(CellView(icon: "gamecontroller", text: "Game", action: { self.router.toLevelSelect = true })),
					AnyView(CellView(icon: "square.grid.3x3.topmiddle.filled", text: "Target", action: { self.router.toTargetSelect = true })),
					AnyView(CellView(icon: "chart.bar.xaxis", text: "Statistics", action: {  })),
				])
				.padding()
				Spacer()
			}
		}
		.background(Color.mm_background_secondary)
		.fullScreenCover(isPresented: $router.toBox) {
			SettingsCubeView(dependency: self.dependency, model: SettingsCubeModel(cubeStorage: self.dependency.settingsStorages.settingsCubeStorage))
		}
		.fullScreenCover(isPresented: $router.toStars) {
			SettingsAsteroids(asteroidsModel: SettingsAsteroidsModel(asteroidsStorage: self.dependency.settingsStorages.settingsAsteroidsStorage))
		}
		.fullScreenCover(isPresented: $router.toLevelSelect) {
			LevelSelectionView(gameModel: LevelSelectionModel(gameStorage: self.dependency.settingsStorages.settingsGameStorage))
		}
		.fullScreenCover(isPresented: $router.toTargetSelect) {
			TargetSelectionView(dependncy: self.dependency)
		}
	}
}

#Preview {
    OptionsView(dependency: MockDependency())
}

final class MockSettingsStorage: _SettingsStorage {
	var settingsGameStorage: _SettingsGameStorage = MockSettingsGameStorage()
    var settingsCubeStorage: _SettingsCubeStorage = MockSettingsCubeStorage()
    var settingsAsteroidsStorage: _SettingsAsteroidsStorage = MockSettingsAsteroidsStorage()
}
