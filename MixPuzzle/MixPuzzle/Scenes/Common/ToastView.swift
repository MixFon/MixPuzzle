//
//  ToastView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 07.11.2026.
//

import SwiftUI

/// Уведомление-«остров»: короткий заголовок и необязательное пояснение
struct Toast: Identifiable, Equatable {
	let id = UUID()
	let style: ToastStyle
	let title: String
	let message: String?

	static func success(_ title: String, message: String? = nil) -> Toast {
		Toast(style: .success, title: title, message: message)
	}

	static func warning(_ title: String, message: String? = nil) -> Toast {
		Toast(style: .warning, title: title, message: message)
	}

	static func error(_ title: String, message: String? = nil) -> Toast {
		Toast(style: .error, title: title, message: message)
	}
}

enum ToastStyle {
	case success
	case warning
	case error

	var color: Color {
		switch self {
		case .success:
			return .mm_green
		case .warning:
			return .mm_warning
		case .error:
			return .mm_danger
		}
	}

	var iconName: String {
		switch self {
		case .success:
			return "checkmark"
		case .warning:
			return "exclamationmark"
		case .error:
			return "xmark"
		}
	}

	/// Сколько секунд остров виден, если его не трогать
	var duration: Double {
		switch self {
		case .success:
			return 2
		case .warning:
			return 3.5
		case .error:
			return 5
		}
	}
}

/// Вид острова. В свёрнутом виде пояснение обрезается до одной строки,
/// в раскрытом показывается целиком.
struct ToastView: View {
	let toast: Toast
	let isExpanded: Bool

	var body: some View {
		HStack(alignment: self.isExpanded ? .top : .center, spacing: 10) {
			Image(systemName: self.toast.style.iconName)
				.font(.system(size: 15, weight: .heavy))
				.foregroundStyle(Color.white)
				.frame(width: 34, height: 34)
				.background(self.toast.style.color, in: Circle())
			VStack(alignment: .leading, spacing: 2) {
				Text(self.toast.title)
					.font(.subheadline.weight(.bold))
					.foregroundStyle(Color.mm_text_primary)
					.lineLimit(self.isExpanded ? nil : 1)
				if let message = self.toast.message {
					Text(message)
						.font(.caption)
						.foregroundStyle(Color.mm_text_secondary)
						.lineLimit(self.isExpanded ? nil : 1)
						.fixedSize(horizontal: false, vertical: self.isExpanded)
				}
			}
			.padding(.trailing, 10)
			.padding(.vertical, self.isExpanded ? 4 : 0)
		}
		.padding(8)
		.frame(maxWidth: self.isExpanded ? .infinity : nil, alignment: .leading)
		.glassBackground(in: RoundedRectangle(cornerRadius: 25, style: .continuous))
		.accessibilityElement(children: .combine)
		.accessibilityAddTraits(.isStaticText)
	}
}

/// Слой с островом поверх всего приложения. Живёт в отдельном прозрачном окне `ToastCenter`.
struct ToastHostView: View {
	@ObservedObject var center: ToastCenter

	/// Смещение при смахивании вверх (только отрицательное)
	@GestureState private var dragOffset: CGFloat = 0

	var body: some View {
		VStack(spacing: 0) {
			if let toast = self.center.current {
				ToastView(toast: toast, isExpanded: self.center.isExpanded)
					.background(
						GeometryReader { geometry in
							Color.clear
								.onAppear {
									self.center.toastFrame = geometry.frame(in: .global)
								}
								.onChange(of: geometry.frame(in: .global)) { frame in
									self.center.toastFrame = frame
								}
						}
					)
					.offset(y: self.dragOffset)
					.onTapGesture {
						self.center.toggleExpanded()
					}
					.gesture(
						DragGesture(coordinateSpace: .global)
							.updating(self.$dragOffset) { value, state, _ in
								state = min(0, value.translation.height)
							}
							.onEnded { value in
								if value.translation.height < -20 || value.predictedEndTranslation.height < -60 {
									self.center.dismiss()
								}
							}
					)
					.transition(.move(edge: .top).combined(with: .opacity))
					.id(toast.id)
			}
		}
		// Ниже стеклянной шапки экранов (44 pt кнопок + отступы)
		.padding(.top, 60)
		.padding(.horizontal, 16)
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
		.animation(.spring(response: 0.4, dampingFraction: 0.82), value: self.center.current?.id)
		.animation(.spring(response: 0.35, dampingFraction: 0.86), value: self.center.isExpanded)
	}
}

#Preview {
	VStack(spacing: 16) {
		ToastView(toast: .success("Saved", message: "Cube appearance"), isExpanded: false)
		ToastView(toast: .warning("Matrix filled incorrectly", message: "Numbers from 0 to 15 without duplicates are required."), isExpanded: false)
		ToastView(toast: .error("No solution", message: "It is impossible to reach the «Snail» state from the current layout."), isExpanded: true)
	}
	.padding()
	.frame(maxWidth: .infinity, maxHeight: .infinity)
	.background(Color.indigo)
}
