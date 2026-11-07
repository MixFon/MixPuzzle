//
//  SettingsAsteroids.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 29.04.2024.
//

import SwiftUI

final class SettingsAsteroidsModel: ObservableObject {
    
    @Published var radiusSphere: Double
    @Published var asteroidsCount: Double
    @Published var isShowAsteroids: Bool
    
    private var asteroidsStorage: _SettingsAsteroidsStorage
    
    init(asteroidsStorage: _SettingsAsteroidsStorage) {
        self.asteroidsStorage = asteroidsStorage
        self.radiusSphere = asteroidsStorage.radiusSphere
        self.asteroidsCount = asteroidsStorage.asteroidsCount
        self.isShowAsteroids = asteroidsStorage.isShowAsteroids
    }
    
    func saveChanges() {
        self.asteroidsStorage.radiusSphere = self.radiusSphere
        self.asteroidsStorage.asteroidsCount = self.asteroidsCount
        self.asteroidsStorage.isShowAsteroids = self.isShowAsteroids
    }
}

struct SettingsAsteroidsView: View {
    
	let dependency: _Dependency
    @ObservedObject var asteroidsModel: SettingsAsteroidsModel
    
    var body: some View {
		SettingsPreviewLayout(title: "Asteroids".localized, panelTitle: self.panelTitle, onSave: {
			self.asteroidsModel.saveChanges()
			self.dependency.workers.toastPresenter.show(.success("mix.toast.saved".localized, message: self.panelTitle))
		}) {
			SettingsAsteroidsWrapper(model: self.asteroidsModel, dependency: self.dependency)
				.id("setting_asteroids_static_id")
		} panel: {
			ScrollView {
				VStack(spacing: 16) {
					SettingsPanelGroup {
						ToggleCellView(icon: "moon.stars", text: "Show asteroids".localized, isOn: $asteroidsModel.isShowAsteroids)
					}
					// Количество и радиус имеют смысл, только когда астероиды показаны
					SettingsPanelGroup {
						SliderCellView(title: "Asteroids count".localized, range: 0...200, value: $asteroidsModel.asteroidsCount)
						SliderCellView(title: "Asteroid radius".localized, range: 20...40, value: $asteroidsModel.radiusSphere)
					}
					.disabled(!self.asteroidsModel.isShowAsteroids)
					.opacity(self.asteroidsModel.isShowAsteroids ? 1 : 0.4)
					.animation(.easeInOut(duration: 0.2), value: self.asteroidsModel.isShowAsteroids)
				}
				.padding(.bottom, 24)
			}
		}
    }
	
	private let panelTitle = String(localized: "mix.settings.panel.asteroids", comment: "Title of settings panel on asteroids settings screen")
}

#Preview {
    let settingsAteroidsDependency = SettingsAsteroidsModel(asteroidsStorage: MockSettingsAsteroidsStorage())
    return SettingsAsteroidsView(dependency: MockDependency(), asteroidsModel: settingsAteroidsDependency)
}

final class MockSettingsAsteroidsStorage: _SettingsAsteroidsStorage {
    var radiusSphere: Double = 30
    var asteroidsCount: Double = 100
    var isShowAsteroids: Bool = true
}
