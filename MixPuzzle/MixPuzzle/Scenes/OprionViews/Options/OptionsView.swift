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
	private let cube = String(localized: "Cube", comment: "Name of cell in options screen")
	private let lighting = String(localized: "Lighting")
	private let asteroids = String(localized: "Asteroids", comment: "Name of cell in options screen")
	private let vibration = String(localized: "Vibration", comment: "Name cell in options")
	private let statistic = String(localized: "Statistic")
	private let boardSize = String(localized: "mix.options.board.size", comment: "Title of board size section in options")
	private let target = String(localized: "mix.options.target", comment: "Title of target section in options")

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
					self.levelSection
					self.targetSection
					self.graphicsSection
					self.applicationSection
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

	// MARK: Размер поля

	private var levelSection: some View {
		OptionsCard {
			HStack(alignment: .firstTextBaseline) {
				Text(self.boardSize)
					.font(.headline)
					.foregroundStyle(Color.mm_text_primary)
				Spacer()
				Text(String(format: "mix.options.board.size.subtitle".localized, self.model.currentLevel, self.model.currentLevel, self.model.currentLevel * self.model.currentLevel - 1))
					.font(.subheadline)
					.foregroundStyle(Color.mm_text_secondary)
			}
			LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 8), spacing: 6) {
				ForEach(self.model.levels, id: \.self) { level in
					LevelChip(
						level: level,
						isSelected: level == self.model.currentLevel,
						isLocked: level > self.model.maxAchievedLevel
					) {
						self.model.currentLevel = level
					}
				}
			}
		}
	}

	// MARK: Цель сборки

	private var targetSection: some View {
		OptionsCard {
			Text(self.target)
				.font(.headline)
				.foregroundStyle(Color.mm_text_primary)
			HStack(spacing: 10) {
				ForEach(Solution.displayOrder, id: \.self) { solution in
					TargetCard(solution: solution, isSelected: solution == self.model.solution) {
						self.model.solution = solution
					}
				}
			}
			Text(self.model.solution.localizedDescription)
				.font(.footnote)
				.foregroundStyle(Color.mm_text_secondary)
				.fixedSize(horizontal: false, vertical: true)
				.animation(.none, value: self.model.solution)
		}
	}

	// MARK: Графика

	private var graphicsSection: some View {
		HStack(spacing: 10) {
			GraphicsTile(icon: "cube", title: self.cube, subtitle: self.model.cubeSubtitle) {
				self.router.toBox = true
			}
			GraphicsTile(icon: "moon.stars", title: self.asteroids, subtitle: self.model.asteroidsSubtitle) {
				self.router.toStars = true
			}
			GraphicsTile(icon: "lightbulb.max", title: self.lighting, subtitle: self.model.lightSubtitle) {
				self.router.toLight = true
			}
		}
	}

	// MARK: Приложение

	private var applicationSection: some View {
		VStack(spacing: 0) {
			Toggle(isOn: self.$model.isUseVibration) {
				Label {
					Text(self.vibration)
						.foregroundStyle(Color.mm_text_primary)
				} icon: {
					Image(systemName: "waveform.path")
						.foregroundStyle(Color.mm_text_secondary)
				}
			}
			.tint(Color.mm_green)
			.frame(minHeight: 56)
			if #available(iOS 16.0, *) {
				Divider()
				Button {
					self.router.toStatistics = true
				} label: {
					HStack(spacing: 12) {
						Label {
							Text(self.statistic)
								.foregroundStyle(Color.mm_text_primary)
						} icon: {
							Image(systemName: "chart.bar.xaxis")
								.foregroundStyle(Color.mm_text_secondary)
						}
						Spacer()
						Image(systemName: "chevron.right")
							.font(.footnote.weight(.semibold))
							.foregroundStyle(Color.mm_tint_icons)
					}
					.frame(minHeight: 56)
					.contentShape(Rectangle())
				}
				.buttonStyle(.plain)
			}
		}
		.padding(.horizontal, 16)
		.background(Color.mm_background_tertiary)
		.clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
	}
}

// MARK: - Компоненты экрана настроек

/// Карточка-секция со скруглением
private struct OptionsCard<Content: View>: View {
	@ViewBuilder let content: Content

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			self.content
		}
		.padding(16)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(Color.mm_background_tertiary)
		.clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
	}
}

/// Кнопка выбора размера поля
private struct LevelChip: View {
	let level: Int
	let isSelected: Bool
	let isLocked: Bool
	let action: () -> Void

	var body: some View {
		Button(action: self.action) {
			ZStack {
				if self.isLocked {
					Image(systemName: "lock.fill")
						.font(.footnote)
						.foregroundStyle(Color.mm_text_secondary)
				} else {
					Text("\(self.level)")
						.font(.callout.weight(.bold))
						.foregroundStyle(self.isSelected ? Color.white : Color.mm_text_primary)
				}
			}
			.frame(maxWidth: .infinity, minHeight: 44)
			.background(self.isSelected ? Color.mm_tint_secondary : Color.mm_background_secondary)
			.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
			.overlay(
				RoundedRectangle(cornerRadius: 12, style: .continuous)
					.stroke(self.isSelected ? Color.clear : Color.mm_text_secondary.opacity(0.25), lineWidth: 1)
			)
		}
		.buttonStyle(.plain)
		.disabled(self.isLocked)
		.accessibilityLabel("\(self.level) × \(self.level)")
		.accessibilityAddTraits(self.isSelected ? .isSelected : [])
	}
}

/// Карточка целевой раскладки с мини-схемой 3×3
private struct TargetCard: View {
	let solution: Solution
	let isSelected: Bool
	let action: () -> Void

	var body: some View {
		Button(action: self.action) {
			VStack(spacing: 8) {
				LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 3), spacing: 3) {
					ForEach(Array(self.solution.previewCells.enumerated()), id: \.offset) { _, value in
						self.cell(value)
					}
				}
				Text(self.solution.name)
					.font(.caption.weight(.semibold))
					.foregroundStyle(Color.mm_text_primary)
					.lineLimit(1)
					.minimumScaleFactor(0.7)
			}
			.padding(10)
			.background(Color.mm_background_secondary)
			.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
			.overlay(
				RoundedRectangle(cornerRadius: 16, style: .continuous)
					.stroke(self.isSelected ? Color.mm_tint_secondary : Color.mm_text_secondary.opacity(0.25), lineWidth: 2)
			)
		}
		.buttonStyle(.plain)
		.accessibilityAddTraits(self.isSelected ? .isSelected : [])
	}

	@ViewBuilder
	private func cell(_ value: Int) -> some View {
		if value == 0 {
			RoundedRectangle(cornerRadius: 5, style: .continuous)
				.strokeBorder(Color.mm_text_secondary.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [3]))
				.aspectRatio(1, contentMode: .fit)
		} else {
			RoundedRectangle(cornerRadius: 5, style: .continuous)
				.fill(self.isSelected ? Color.mm_text_primary : Color.mm_text_secondary.opacity(0.3))
				.aspectRatio(1, contentMode: .fit)
				.overlay(
					Text("\(value)")
						.font(.system(size: 11, weight: .bold))
						.foregroundStyle(self.isSelected ? Color.mm_background_tertiary : Color.mm_text_primary)
				)
		}
	}
}

/// Плитка перехода к настройкам графики
private struct GraphicsTile: View {
	let icon: String
	let title: String
	let subtitle: String
	let action: () -> Void

	var body: some View {
		Button(action: self.action) {
			VStack(alignment: .leading, spacing: 0) {
				Image(systemName: self.icon)
					.font(.title2)
					.foregroundStyle(Color.mm_tint_secondary)
				Spacer(minLength: 12)
				Text(self.title)
					.font(.subheadline.weight(.semibold))
					.foregroundStyle(Color.mm_text_primary)
					.lineLimit(1)
					.minimumScaleFactor(0.8)
				Text(self.subtitle)
					.font(.caption)
					.foregroundStyle(Color.mm_text_secondary)
					.lineLimit(1)
			}
			.padding(.horizontal, 12)
			.padding(.vertical, 14)
			.frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
			.background(Color.mm_background_tertiary)
			.clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
		}
		.buttonStyle(.plain)
	}
}

private extension Solution {
	/// Порядок карточек на экране
	static let displayOrder: [Solution] = [.classic, .snail, .boustrophedon]

	/// Схема 3×3 для превью (0 — пустая клетка)
	var previewCells: [Int] {
		switch self {
		case .classic:
			return [1, 2, 3, 4, 5, 6, 7, 8, 0]
		case .snail:
			return [1, 2, 3, 8, 0, 4, 7, 6, 5]
		case .boustrophedon:
			return [1, 2, 3, 6, 5, 4, 7, 8, 0]
		}
	}

	var localizedDescription: String {
		switch self {
		case .snail:
			return "mix.description.solution.snail".localized
		case .classic:
			return "mix.description.solution.classic".localized
		case .boustrophedon:
			return "mix.description.solution.boustrophedon".localized
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
