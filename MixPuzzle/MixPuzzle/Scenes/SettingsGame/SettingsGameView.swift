//
//  SettingsGameView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 09.05.2024.
//

import SwiftUI
import Combine

final class SettingsGameModel: ObservableObject {
	
	@Published var currentLevel: Int
	
	private var gameStorage: _SettingsGameStorage
	private var cancellables = Set<AnyCancellable>()
	
	init(gameStorage: _SettingsGameStorage) {
		self.gameStorage = gameStorage
		self.currentLevel = gameStorage.currentLevel
	}
	
	func saveChanges() {
		self.gameStorage.currentLevel = self.currentLevel
	}
}

struct SettingsGameView: View {
	
	@ObservedObject var gameModel: SettingsGameModel
	@State private var isShowSnackbar = false
	
    var body: some View {
		VStack {
			NavigationBar(title: "Settings Game", tralingView: AnyView(
				SaveButtonNavigationBar(action: {
					self.isShowSnackbar = true
					self.gameModel.saveChanges()
				})
			))
			.padding()
			SelectLevelView(currentLevel: self.gameModel.currentLevel)
				.background(Color.mm_background_tertiary)
		}
		.snackbar(isShowing: $isShowSnackbar, text: "The data has been saved successfully.", style: .success, extraBottomPadding: 16)
		.background(Color.mm_background_tertiary)
    }
}

#Preview {
	let settingsGameModel = SettingsGameModel(gameStorage: MockSettingsGameStorage())
	return SettingsGameView(gameModel: settingsGameModel)
}
