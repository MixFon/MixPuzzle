//
//  FeedbackGenerator.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 09.05.2025.
//

import SceneKit

/// Протокол предназначенный для настройи тактильной отдачи
@MainActor
protocol _FeedbackGenerator {
	func emit()
	func error()
}

final class FeedbackGenerator: _FeedbackGenerator {
	
	private let settingsGameStorage: _SettingsGameStorage
	
	init(settingsGameStorage: _SettingsGameStorage) {
		self.settingsGameStorage = settingsGameStorage
	}
		
	private lazy var notificationGenerator: UINotificationFeedbackGenerator = {
		UINotificationFeedbackGenerator()
	}()
	
	private lazy var impactGenerator: UIImpactFeedbackGenerator = {
		UIImpactFeedbackGenerator(style: .soft)
	}()
	
	func emit() {
		guard settingsGameStorage.isUseVibration else { return }
		self.impactGenerator.prepare()
		self.impactGenerator.impactOccurred()
	}
		
	func error() {
		guard settingsGameStorage.isUseVibration else { return }
		self.notificationGenerator.prepare()
		self.notificationGenerator.notificationOccurred(.error)
	}
	
}
