//
//  FeedbackGenerator.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 09.05.2025.
//

import SceneKit

/// Протокол предназначенный для настройи тактильной отдачи
protocol _FeedbackGenerator: Actor {
	func emit()
	func error()
}

final actor FeedbackGenerator: _FeedbackGenerator, Sendable {
	
	private let settingsGameStorage: _SettingsGameStorage
	
	init(settingsGameStorage: _SettingsGameStorage) {
		self.settingsGameStorage = settingsGameStorage
	}
		
	@MainActor
	private lazy var notificationGenerator: UINotificationFeedbackGenerator = {
		UINotificationFeedbackGenerator()
	}()
	
	@MainActor
	private lazy var impactGenerator: UIImpactFeedbackGenerator = {
		UIImpactFeedbackGenerator(style: .soft)
	}()
	
	func emit() {
		guard settingsGameStorage.isUseVibration else { return }
		Task { @MainActor in
			self.impactGenerator.prepare()
			self.impactGenerator.impactOccurred()
		}
	}
		
	func error() {
		guard settingsGameStorage.isUseVibration else { return }
		Task { @MainActor in
			self.notificationGenerator.prepare()
			self.notificationGenerator.notificationOccurred(.error)
		}
	}
	
}
