//
//  ContentView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 20.02.2024.
//

import SwiftUI
import SceneKit
import MFPuzzle

final class MenuViewRouter: ObservableObject {
	@Published var toStart: Bool = false
	@Published var toOprionts: Bool = false
	@Published var toFindSolution: Bool = false
}

struct MenuView: View {
    
    let dependency: _Dependency
	@ObservedObject private var router = MenuViewRouter()
	
	var body: some View {
		MenuSceneWrapper(toStart: $router.toStart, toOprionts: $router.toOprionts, toFindSolution: $router.toFindSolution)
			.fullScreenCover(isPresented: self.$router.toStart) {
				StartView(dependency: self.dependency)
			}
			.fullScreenCover(isPresented: self.$router.toOprionts) {
				OptionsView(dependency: self.dependency)
			}
			.fullScreenCover(isPresented: self.$router.toFindSolution) {
				FindSolutionView(dependency: self.dependency)
			}
			.edgesIgnoringSafeArea(.all)
	}
}

#Preview {
    let dependency = MockDependency()
    return MenuView(dependency: dependency)
}

final class MockDependency: _Dependency {
	var workers: _Workers = MockWorkers()
    var settingsStorages: _SettingsStorage = MockSettingsStorage()
}
