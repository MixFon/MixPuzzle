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
	@Published var toLight: Bool = false
	@Published var toLanguage: Bool = false
	@Published var toStatistics: Bool = false
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
	
	private let cube = String(localized: "Cube", comment: "Name of cell in options screen")
	private let game = String(localized: "Game")
	private let title = String(localized: "Options")
	private let lighting = String(localized: "Lighting")
	private let graphics = String(localized: "Garaphics", comment: "Name of section in options screen")
	private let asteroids = String(localized: "Asteroids", comment: "Name of cell in options screen")
	private let vibration = String(localized: "Vibration", comment: "Name cell in options")
	private let scatistic = String(localized: "Statistic")
	private let aplication = String(localized: "Application", comment: "Name of section in options screen")
	private let choiseOFLevel = String(localized: "Levels")
	private let choiseOfTarget = String(localized: "Targets")
	
	init(dependency: _Dependency) {
		self.dependency = dependency
		self.model = OptionsViewModel(settingsGameStorage: dependency.settingsStorages.settingsGameStorage)
	}
	
	var body: some View {
		VStack {
			NavigationBar(title: self.title)
				.padding()
			ScrollView {
				OptionsSectionsView(title: self.graphics, cells: [
					AnyView(CellView(icon: "cube", text: self.cube, action: { self.router.toBox = true })),
					AnyView(CellView(icon: "moon.stars", text: self.asteroids, action: { self.router.toStars = true })),
					AnyView(CellView(icon: "lightbulb.max", text: self.lighting, action: { self.router.toLight = true })),
				])
				.padding()
				OptionsSectionsView(title: self.aplication, cells: [
					AnyView(ToggleCellView(icon: "waveform.path", text: self.vibration, isOn: self.$model.isUseVibration)),
				])
				.padding()
				OptionsSectionsView(title: self.game, cells: self.gameSectionCells)
				.padding()
				Spacer()
			}
		}
		.background(Color.mm_background_secondary)
		.fullScreenCover(isPresented: $router.toBox) {
			SettingsCubeView(dependency: self.dependency, model: SettingsCubeModel(cubeStorage: self.dependency.settingsStorages.settingsCubeStorage))
		}
		.fullScreenCover(isPresented: $router.toStars) {
			SettingsAsteroidsView(asteroidsModel: SettingsAsteroidsModel(asteroidsStorage: self.dependency.settingsStorages.settingsAsteroidsStorage))
		}
		.fullScreenCover(isPresented: $router.toLevelSelect) {
			LevelSelectionView(gameModel: LevelSelectionModel(gameStorage: self.dependency.settingsStorages.settingsGameStorage))
		}
		.fullScreenCover(isPresented: $router.toTargetSelect) {
			TargetSelectionView(dependncy: self.dependency)
		}
		.fullScreenCover(isPresented: $router.toLight) {
			SettingsLightView(lightModel: SettingsLightModel(lightStorage: self.dependency.settingsStorages.settingsLightStorage))
		}
		.fullScreenCover(isPresented: $router.toStatistics) {
			if #available(iOS 16.0, *) {
				StatisticsView(statisticsData: self.dependency.workers.gameWorker.getStatistics())
			}
		}
	}
	
	private var gameSectionCells: [AnyView] {
		var cells = [
			AnyView(CellView(icon: "gamecontroller", text: self.choiseOFLevel, action: { self.router.toLevelSelect = true })),
			AnyView(CellView(icon: "square.grid.3x3.topmiddle.filled", text: self.choiseOfTarget, action: { self.router.toTargetSelect = true })),
		]
		if #available(iOS 16.0, *) {
			cells.append(AnyView(CellView(icon: "chart.bar.xaxis", text: self.scatistic, action: { self.router.toStatistics = true })))
		}
		return cells
	}
}

#Preview {
    OptionsView(dependency: MockDependency())
}

final class MockSettingsStorage: _SettingsStorage {
	var settingsGameStorage: any _SettingsGameStorage = MockSettingsGameStorage()
    var settingsCubeStorage: any _SettingsCubeStorage = MockSettingsCubeStorage()
	var settingsLightStorage: any _SettingsLightStorage = MockSettingsLightStorage()
    var settingsAsteroidsStorage: any _SettingsAsteroidsStorage = MockSettingsAsteroidsStorage()
}
