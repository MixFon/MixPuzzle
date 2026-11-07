//
//  ManualFillingStatusView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 07.11.2026.
//

import SwiftUI
import MFPuzzle

/// Строка над полем: «Перемешать», состояние расстановки и «Почему?».
/// Если решения нет, ниже появляется подсказка с кнопкой «Исправить».
struct ManualFillingStatusView: View {
	let status: ManualFillingModel.Status
	/// Значения в клетках, которые предлагается поменять местами (для текста подсказки)
	var swapValues: (MatrixElement, MatrixElement)? = nil
	let onShuffle: () -> Void
	let onInfo: () -> Void
	let onFix: () -> Void

	var body: some View {
		VStack(spacing: 10) {
			HStack(spacing: 8) {
				Button(action: self.onShuffle) {
					Image(systemName: "shuffle")
						.font(.body.weight(.semibold))
						.foregroundStyle(Color.mm_text_primary)
						.frame(width: 40, height: 40)
						.glassBackground(in: Circle())
				}
				.buttonStyle(.plain)
				.accessibilityLabel("mix.manual.shuffle".localized)

				HStack(spacing: 8) {
					Circle()
						.fill(self.statusColor)
						.frame(width: 10, height: 10)
					Text(self.statusText)
						.font(.subheadline.weight(.semibold))
						.foregroundStyle(Color.mm_text_primary)
						.lineLimit(1)
						.minimumScaleFactor(0.8)
					Spacer(minLength: 0)
				}
				.padding(.horizontal, 12)
				.frame(maxWidth: .infinity, minHeight: 40)
				.glassBackground(in: Capsule())
				.accessibilityElement(children: .combine)

				Button(action: self.onInfo) {
					Image(systemName: "questionmark")
						.font(.body.weight(.heavy))
						.foregroundStyle(self.isUnsolvable ? Color.white : Color.mm_text_primary)
						.frame(width: 40, height: 40)
						.glassBackground(in: Circle(), tint: self.isUnsolvable ? .mm_danger : nil)
				}
				.buttonStyle(.plain)
				.accessibilityLabel("mix.manual.why".localized)
			}
			if self.isUnsolvable {
				HStack(spacing: 12) {
					Text(self.hintText)
						.font(.footnote)
						.foregroundStyle(Color.mm_text_primary)
						.fixedSize(horizontal: false, vertical: true)
						.frame(maxWidth: .infinity, alignment: .leading)
					Button(action: self.onFix) {
						Text("mix.manual.fix".localized)
							.font(.subheadline.weight(.semibold))
							.foregroundStyle(Color.mm_text_primary)
							.padding(.horizontal, 12)
							.frame(minHeight: 44)
							.background(Color.mm_text_primary.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
					}
					.buttonStyle(.plain)
				}
				.padding(.leading, 14)
				.padding(.trailing, 8)
				.padding(.vertical, 8)
				.glassBackground(in: RoundedRectangle(cornerRadius: 18, style: .continuous))
				.transition(.move(edge: .top).combined(with: .opacity))
			}
		}
		.animation(.spring(response: 0.35, dampingFraction: 0.86), value: self.isUnsolvable)
	}

	private var isUnsolvable: Bool {
		if case .unsolvable = self.status {
			return true
		}
		return false
	}

	private var statusColor: Color {
		switch self.status {
		case .incomplete:
			return .mm_text_secondary
		case .duplicate, .unsolvable:
			return .mm_danger
		case .solvable:
			return .mm_green
		}
	}

	private var statusText: String {
		switch self.status {
		case let .incomplete(filled, total):
			return String(format: "mix.manual.status.filled".localized, filled, total)
		case .duplicate(0):
			return "mix.manual.status.duplicate.blank".localized
		case let .duplicate(value):
			return String(format: "mix.manual.status.duplicate".localized, Int(value))
		case .solvable:
			return "mix.manual.status.solvable".localized
		case .unsolvable:
			return "mix.manual.status.unsolvable".localized
		}
	}

	private var hintText: String {
		if let (first, second) = self.swapValues {
			return String(format: "mix.manual.hint.swap".localized, Int(first), Int(second))
		}
		return "mix.manual.hint".localized
	}
}

#Preview {
	VStack(spacing: 24) {
		ManualFillingStatusView(status: .incomplete(filled: 12, total: 16), onShuffle: {}, onInfo: {}, onFix: {})
		ManualFillingStatusView(status: .duplicate(value: 7), onShuffle: {}, onInfo: {}, onFix: {})
		ManualFillingStatusView(status: .solvable, onShuffle: {}, onInfo: {}, onFix: {})
		ManualFillingStatusView(status: .unsolvable(swapFirst: 13, swapSecond: 14), swapValues: (14, 15), onShuffle: {}, onInfo: {}, onFix: {})
	}
	.padding()
	.frame(maxHeight: .infinity)
	.background(Color.indigo)
}
