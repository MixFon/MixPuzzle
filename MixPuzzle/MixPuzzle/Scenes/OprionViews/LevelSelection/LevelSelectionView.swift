//
//  LevelSelectionView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 09.05.2024.
//

import SwiftUI
import Combine

final class LevelSelectionModel: ObservableObject {
	
	@Published var currentLevel: Int
	@Published var maxAchievedLevel: Int
	let availableLevel: Int
	
	private var gameStorage: _SettingsGameStorage
	private var cancellables = Set<AnyCancellable>()
	
	init(gameStorage: _SettingsGameStorage) {
		self.gameStorage = gameStorage
		self.currentLevel = gameStorage.currentLevel
		self.availableLevel = gameStorage.availableLevel
		self.maxAchievedLevel = gameStorage.maxAchievedLevel
	}
	
	func saveChanges() {
		self.gameStorage.currentLevel = self.currentLevel
	}
}

struct LevelSelectionView: View {
	
	@ObservedObject var gameModel: LevelSelectionModel
	@State private var isShowSnackbar = false
	
	private let title = String(localized: "Levels", comment: "Title choice of the level screen")
	private let snackbarSaveMessage = String(localized: "mix.snackbar.saved")
	
    var body: some View {
		VStack {
			NavigationBar(title: self.title, tralingView: AnyView(
				ButtonNavigationBar(title: "Save".localized, action: {
					self.isShowSnackbar = true
					self.gameModel.saveChanges()
				})
			))
			.padding()
			SelectLevelView(items: Array(3...gameModel.availableLevel), maxAchievedLevel: self.gameModel.maxAchievedLevel, selectNumber: self.$gameModel.currentLevel)
				.background(Color.mm_background_tertiary)
		}
		.snackbar(isShowing: $isShowSnackbar, text: self.snackbarSaveMessage, style: .success, extraBottomPadding: 16)
		.background(Color.mm_background_tertiary)
    }
}

#Preview {
	let settingsGameModel = LevelSelectionModel(gameStorage: MockSettingsGameStorage())
	return LevelSelectionView(gameModel: settingsGameModel)
}
