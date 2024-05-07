//
//  ContentView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 20.02.2024.
//

import SwiftUI
import SceneKit
import MFPuzzle

struct MenuView: View {
    
    let dependency: _Dependency
	
	@State private var toStart: Bool = false
	@State private var toOprionts: Bool = false
	
	var body: some View {
		MenuSceneWrapper(toStart: $toStart, toOprionts: $toOprionts)
			.fullScreenCover(isPresented: self.$toStart) {
				StartView(dependency: self.dependency)
			}
			.fullScreenCover(isPresented: self.$toOprionts) {
                OptionsView(settingsStorages: self.dependency.settingsStorages)
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
