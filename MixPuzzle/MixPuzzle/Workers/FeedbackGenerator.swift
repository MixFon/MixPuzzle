//
//  FeedbackGenerator.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 09.05.2025.
//

import SceneKit

/// Протокол предназначенный для настройи тактильной отдачи
protocol _FeedbackGenerator {
	func emit()
	func error()
}

final class FeedbackGenerator: _FeedbackGenerator {
	
	private lazy var notificationGenerator: UINotificationFeedbackGenerator = {
		UINotificationFeedbackGenerator()
	}()
	
	private lazy var impactGenerator: UIImpactFeedbackGenerator = {
		UIImpactFeedbackGenerator(style: .soft)
	}()
	
	func emit() {
		self.impactGenerator.prepare()
		self.impactGenerator.impactOccurred()
	}
		
	func error() {
		self.notificationGenerator.prepare()
		self.notificationGenerator.notificationOccurred(.error)
	}
	
}
