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

struct SettingsAsteroids: View {
    
    @ObservedObject var asteroidsModel: SettingsAsteroidsModel
    @State private var isShowSnackbar: Bool = false
    
    var body: some View {
        VStack {
            NavigationBar(title: "Settings Asteroids", tralingView: AnyView(
                SaveButtonNavigationBar(action: {
                    self.asteroidsModel.saveChanges()
					self.isShowSnackbar = true
                })
            ))
            .padding()
            ScrollView {
                OptionsSectionsView(title: "Asteroids", cells: [
                    AnyView(ToggleCellView(icon: "waveform.path", text: "Show Asteroids", isOn: $asteroidsModel.isShowAsteroids)),
                    AnyView(SliderCellView(title: "Asteroids Count", range: 0...200, radius: $asteroidsModel.asteroidsCount)),
                    AnyView(SliderCellView(title: "Radius Sphere Asteroids", range: 20...40, radius: $asteroidsModel.radiusSphere)),
                ])
            }
            .cornerRadius(16)
            .padding()
        }
		.snackbar(isShowing: $isShowSnackbar, text: "The data has been saved successfully.", style: .success, extraBottomPadding: 16)
        .background(Color.mm_background_secondary)
    }
}

#Preview {
    let settingsAteroidsDependency = SettingsAsteroidsModel(asteroidsStorage: MockSettingsAsteroidsStorage())
    return SettingsAsteroids(asteroidsModel: settingsAteroidsDependency)
}

final class MockSettingsAsteroidsStorage: _SettingsAsteroidsStorage {
    var radiusSphere: Double = 30
    var asteroidsCount: Double = 100
    var isShowAsteroids: Bool = true
}
