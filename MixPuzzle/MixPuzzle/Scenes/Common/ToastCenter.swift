//
//  ToastCenter.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 07.11.2026.
//

import SwiftUI
import UIKit

/// Показ уведомлений-«островов» из любого места приложения
@MainActor
protocol _ToastPresenter: AnyObject {
	/// Показывает остров. Если сейчас виден другой, новый встаёт в очередь.
	func show(_ toast: Toast)
	/// Скрывает текущий остров
	func dismiss()
}

/// Очередь островов и отдельное прозрачное окно над всеми экранами.
/// Отдельное окно нужно, чтобы остров был виден и поверх `fullScreenCover`.
@MainActor
final class ToastCenter: ObservableObject, _ToastPresenter {

	@Published private(set) var current: Toast?
	@Published private(set) var isExpanded = false
	/// Рамка острова в координатах окна: только по ней окно принимает касания
	var toastFrame: CGRect = .zero

	private var queue: [Toast] = []
	private var window: PassthroughWindow?
	private var dismissTask: Task<Void, Never>?

	func show(_ toast: Toast) {
		// Тот же текст уже на экране — просто продлеваем показ
		if let current = self.current, current.title == toast.title, current.message == toast.message {
			self.scheduleDismiss(for: current)
			return
		}
		self.queue.append(toast)
		if self.current == nil {
			self.presentNext()
		}
	}

	func dismiss() {
		self.dismissTask?.cancel()
		guard self.current != nil else { return }
		self.current = nil
		self.isExpanded = false
		self.toastFrame = .zero
		Task { [weak self] in
			// Даём острову уехать, прежде чем показать следующий или спрятать окно
			try? await Task.sleep(nanoseconds: 350_000_000)
			guard let self, self.current == nil else { return }
			if self.queue.isEmpty {
				self.window?.isHidden = true
			} else {
				self.presentNext()
			}
		}
	}

	/// Тап раскрывает остров целиком. Раскрытый остров не исчезает сам,
	/// повторный тап сворачивает его и снова запускает таймер.
	func toggleExpanded() {
		guard let current = self.current else { return }
		self.isExpanded.toggle()
		if self.isExpanded {
			self.dismissTask?.cancel()
		} else {
			self.scheduleDismiss(for: current)
		}
	}

	private func presentNext() {
		guard !self.queue.isEmpty else { return }
		self.installWindowIfNeeded()
		self.window?.isHidden = false
		let toast = self.queue.removeFirst()
		self.isExpanded = false
		self.current = toast
		self.scheduleDismiss(for: toast)
		let announcement = [toast.title, toast.message].compactMap { $0 }.joined(separator: ". ")
		UIAccessibility.post(notification: .announcement, argument: announcement)
	}

	private func scheduleDismiss(for toast: Toast) {
		self.dismissTask?.cancel()
		self.dismissTask = Task { [weak self] in
			try? await Task.sleep(nanoseconds: UInt64(toast.style.duration * 1_000_000_000))
			guard !Task.isCancelled, let self, self.current?.id == toast.id, !self.isExpanded else { return }
			self.dismiss()
		}
	}

	private func installWindowIfNeeded() {
		guard self.window == nil else { return }
		let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
		guard let scene = scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first else { return }
		let window = PassthroughWindow(windowScene: scene)
		window.windowLevel = .alert + 1
		window.backgroundColor = .clear
		window.hitArea = { [weak self] in self?.toastFrame ?? .zero }
		let host = UIHostingController(rootView: ToastHostView(center: self))
		host.view.backgroundColor = .clear
		window.rootViewController = host
		self.window = window
	}
}

/// Окно, которое пропускает касания насквозь везде, кроме острова
private final class PassthroughWindow: UIWindow {
	var hitArea: () -> CGRect = { .zero }

	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		guard self.hitArea().contains(point) else { return nil }
		return super.hitTest(point, with: event)
	}
}
