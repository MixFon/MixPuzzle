//
//  ManualFillingKeypadView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 07.11.2026.
//

import SwiftUI
import MFPuzzle

/// Клавиатура ручного ввода: строка «Пустая клетка» + «Стереть», под ней числа 1…n²−1.
/// Числа, которые уже стоят на поле, приглушены и неактивны.
struct ManualFillingKeypadView: View {
	let size: Int
	let isUsed: (MatrixElement) -> Bool
	let onPut: (MatrixElement) -> Void
	let onErase: () -> Void

	private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 6)

	var body: some View {
		VStack(spacing: 8) {
			HStack(spacing: 8) {
				self.key(title: "mix.manual.blank".localized, font: .subheadline.weight(.semibold), value: 0, dashed: true)
				Button(action: self.onErase) {
					Image(systemName: "delete.left")
						.font(.title3)
						.foregroundStyle(Color.mm_text_secondary)
						.frame(width: 72)
						.frame(minHeight: 46)
						.background(Color.mm_background_secondary.opacity(0.6), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
				}
				.buttonStyle(.plain)
				.accessibilityLabel("mix.manual.erase".localized)
			}
			LazyVGrid(columns: self.columns, spacing: 8) {
				ForEach(1..<(self.size * self.size), id: \.self) { number in
					self.key(title: "\(number)", font: .title3.weight(.bold), value: MatrixElement(number), dashed: false)
				}
			}
		}
	}

	private func key(title: String, font: Font, value: MatrixElement, dashed: Bool) -> some View {
		let used = self.isUsed(value)
		return Button {
			self.onPut(value)
		} label: {
			Text(title)
				.font(font)
				.foregroundStyle(Color.mm_text_primary)
				.lineLimit(1)
				.minimumScaleFactor(0.7)
				.frame(maxWidth: .infinity, minHeight: 46)
				.background(Color.mm_background_secondary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
				.overlay(
					RoundedRectangle(cornerRadius: 12, style: .continuous)
						.strokeBorder(Color.mm_text_secondary.opacity(dashed ? 0.6 : 0), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
				)
		}
		.buttonStyle(.plain)
		.disabled(used)
		.opacity(used ? 0.3 : 1)
	}
}

#Preview {
	ManualFillingKeypadView(size: 4, isUsed: { $0 == 3 || $0 == 7 }, onPut: { debugPrint($0) }, onErase: {})
		.padding()
		.background(Color.mm_background_tertiary)
}
