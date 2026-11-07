//
//  OptionsView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 24.02.2024.
//

import SwiftUI
import MFPuzzle

final class OptionsViewRouter: ObservableObject {
	@Published var toBox: Bool = false
	@Published var toStars: Bool = false
	@Published var toLight: Bool = false
	@Published var toLanguage: Bool = false
	@Published var toStatistics: Bool = false
}

final class OptionsViewModel: ObservableObject {

	@Published var isUseVibration: Bool {
		didSet {
			self.settingsGameStorage.isUseVibration = self.isUseVibration
		}
	}

	/// Выбранный размер поля. Сохраняется сразу при выборе.
	@Published var currentLevel: Int {
		didSet {
			self.settingsGameStorage.currentLevel = self.currentLevel
		}
	}

	/// Выбранная целевая раскладка. Сохраняется сразу при выборе.
	@Published var solution: Solution {
		didSet {
			self.gameWorker.save(solution: self.solution)
		}
	}

	/// Подписи на плитках графики (обновляются после возврата с экрана настройки)
	@Published private(set) var cubeSubtitle: String = ""
	@Published private(set) var asteroidsSubtitle: String = ""
	@Published private(set) var lightSubtitle: String = ""

	let levels: [Int]
	let maxAchievedLevel: Int

	private var settingsGameStorage: _SettingsGameStorage
	private let settingsStorages: _SettingsStorage
	private let gameWorker: _GameWorker

	init(settingsStorages: _SettingsStorage, gameWorker: _GameWorker) {
		self.settingsStorages = settingsStorages
		self.settingsGameStorage = settingsStorages.settingsGameStorage
		self.gameWorker = gameWorker
		self.isUseVibration = settingsGameStorage.isUseVibration
		self.currentLevel = settingsGameStorage.currentLevel
		self.solution = gameWorker.solution
		self.levels = Array(3...settingsGameStorage.availableLevel)
		self.maxAchievedLevel = settingsGameStorage.maxAchievedLevel
		self.refreshSubtitles()
	}

	func refreshSubtitles() {
		let texture = self.settingsStorages.settingsCubeStorage.texture ?? ""
		self.cubeSubtitle = Self.readableTextureName(texture)
		let asteroids = self.settingsStorages.settingsAsteroidsStorage
		self.asteroidsSubtitle = asteroids.isShowAsteroids
			? String(format: "mix.options.asteroids.count".localized, Int(asteroids.asteroidsCount))
			: "mix.options.off".localized
		self.lightSubtitle = self.settingsStorages.settingsLightStorage.lightType.description
	}

	/// "TerrazzoSlab018" → "Terrazzo Slab"
	static func readableTextureName(_ name: String) -> String {
		let base = name.split(separator: "_").first.map(String.init) ?? name
		var result = ""
		for character in base where !character.isNumber {
			if character.isUppercase && !result.isEmpty {
				result.append(" ")
			}
			result.append(character)
		}
		return result
	}
}

struct OptionsView: View {

	private let dependency: _Dependency

	@ObservedObject private var model: OptionsViewModel
	@ObservedObject private var router = OptionsViewRouter()

	private let title = String(localized: "Options")

	init(dependency: _Dependency) {
		self.dependency = dependency
		self.model = OptionsViewModel(
			settingsStorages: dependency.settingsStorages,
			gameWorker: dependency.workers.gameWorker
		)
	}

	var body: some View {
		VStack(spacing: 0) {
			NavigationBar(title: self.title)
				.padding()
			ScrollView {
				VStack(spacing: 14) {
					OptionsLevelSectionView(
						levels: self.model.levels,
						maxAchievedLevel: self.model.maxAchievedLevel,
						currentLevel: self.$model.currentLevel
					)
					OptionsTargetSectionView(solution: self.$model.solution)
					OptionsGraphicsSectionView(
						cubeSubtitle: self.model.cubeSubtitle,
						asteroidsSubtitle: self.model.asteroidsSubtitle,
						lightSubtitle: self.model.lightSubtitle,
						onCube: { self.router.toBox = true },
						onAsteroids: { self.router.toStars = true },
						onLight: { self.router.toLight = true }
					)
					OptionsApplicationSectionView(
						isUseVibration: self.$model.isUseVibration,
						onStatistics: { self.router.toStatistics = true }
					)
				}
				.padding(.horizontal, 16)
				.padding(.bottom, 24)
			}
		}
		.background(Color.mm_background_secondary)
		.fullScreenCover(isPresented: $router.toBox, onDismiss: self.model.refreshSubtitles) {
			SettingsCubeView(dependency: self.dependency, model: SettingsCubeModel(cubeStorage: self.dependency.settingsStorages.settingsCubeStorage))
		}
		.fullScreenCover(isPresented: $router.toStars, onDismiss: self.model.refreshSubtitles) {
			SettingsAsteroidsView(dependency: self.dependency, asteroidsModel: SettingsAsteroidsModel(asteroidsStorage: self.dependency.settingsStorages.settingsAsteroidsStorage))
		}
		.fullScreenCover(isPresented: $router.toLight, onDismiss: self.model.refreshSubtitles) {
			SettingsLightView(dependency: self.dependency, lightModel: SettingsLightModel(lightStorage: self.dependency.settingsStorages.settingsLightStorage))
		}
		.fullScreenCover(isPresented: $router.toStatistics) {
			if #available(iOS 16.0, *) {
				StatisticsView(statisticsData: self.dependency.workers.gameWorker.getStatistics())
			}
		}
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
