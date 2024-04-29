//
//  SettingsAsteroids.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 29.04.2024.
//

import SwiftUI
import Combine

final class SettingsAsteroidsDependency: ObservableObject {
    
    @Published var radiusSphere: Double
    @Published var asteroidsCount: Double
    @Published var isShowAsteroids: Bool
    
    private var asteroidsStorage: _SettingsAsteroidsStorage
    private var cancellables = Set<AnyCancellable>()
    
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
    
    @ObservedObject var dependecy: SettingsAsteroidsDependency
    @State var banner: BannerData = .init(title: "sdf", detail: "sdf", type: .success)
    @State var isShowBanner: Bool = false
    
    var body: some View {
        VStack {
            NavigationBar(title: "Settings Asteroids", tralingView: AnyView(
                SaveButtonNavigationBar(action: {
                    self.dependecy.saveChanges()
                    isShowBanner = true
                })
            ))
            .padding()
            ScrollView {
                OptionsSectionsView(title: "Asteroids", cells: [
                    AnyView(ToggleCellView(icon: "waveform.path", text: "Show Asteroids", isOn: $dependecy.isShowAsteroids)),
                    AnyView(SliderCellView(title: "Asteroids Count", range: 0...200, radius: $dependecy.asteroidsCount)),
                    AnyView(SliderCellView(title: "Radius Sphere Asteroids", range: 20...40, radius: $dependecy.radiusSphere)),
                ])
            }
            .cornerRadius(16)
            .padding()
        }
        .background(Color.mm_background_secondary)
    }
}

#Preview {
    let settingsAteroidsDependency = SettingsAsteroidsDependency(asteroidsStorage: MockSettingsAsteroidsStorage())
    return SettingsAsteroids(dependecy: settingsAteroidsDependency)
}

final class MockSettingsAsteroidsStorage: _SettingsAsteroidsStorage {
    var radiusSphere: Double = 30
    
    var asteroidsCount: Double = 100
    
    var isShowAsteroids: Bool = true
    
    
}
