//
//  FeedbackGenerator.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 09.05.2025.
//

import SceneKit

/// Протокол предназначенный для настройи тактильной отдачи
@MainActor
protocol _FeedbackGenerator: AnyObject, Sendable {
	func emit()
	func error()
}

/// Работает на MainActor, так как UIKit-генераторы отдачи можно использовать только с главного потока
@MainActor
final class FeedbackGenerator: _FeedbackGenerator {
	
	private let settingsGameStorage: _SettingsGameStorage
	
	private lazy var notificationGenerator = UINotificationFeedbackGenerator()
	private lazy var impactGenerator = UIImpactFeedbackGenerator(style: .soft)
	
	init(settingsGameStorage: _SettingsGameStorage) {
		self.settingsGameStorage = settingsGameStorage
	}
	
	func emit() {
		guard self.settingsGameStorage.isUseVibration else { return }
		self.impactGenerator.prepare()
		self.impactGenerator.impactOccurred()
	}
	
	func error() {
		guard self.settingsGameStorage.isUseVibration else { return }
		self.notificationGenerator.prepare()
		self.notificationGenerator.notificationOccurred(.error)
	}
}
