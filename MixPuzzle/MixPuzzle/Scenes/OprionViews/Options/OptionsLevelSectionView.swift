//
//  OptionsLevelSectionView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 07.11.2026.
//

import SwiftUI

/// Секция выбора размера поля
struct OptionsLevelSectionView: View {
	let levels: [Int]
	let maxAchievedLevel: Int
	@Binding var currentLevel: Int

	private let title = String(localized: "mix.options.board.size", comment: "Title of board size section in options")

	var body: some View {
		OptionsCard {
			HStack(alignment: .firstTextBaseline) {
				Text(self.title)
					.font(.headline)
					.foregroundStyle(Color.mm_text_primary)
				Spacer()
				Text(self.subtitle)
					.font(.subheadline)
					.foregroundStyle(Color.mm_text_secondary)
			}
			LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 8), spacing: 6) {
				ForEach(self.levels, id: \.self) { level in
					LevelChip(
						level: level,
						isSelected: level == self.currentLevel,
						isLocked: level > self.maxAchievedLevel
					) {
						self.currentLevel = level
					}
				}
			}
		}
	}

	private var subtitle: String {
		String(format: "mix.options.board.size.subtitle".localized, self.currentLevel, self.currentLevel, self.currentLevel * self.currentLevel - 1)
	}
}

/// Кнопка выбора размера поля
private struct LevelChip: View {
	let level: Int
	let isSelected: Bool
	let isLocked: Bool
	let action: () -> Void

	var body: some View {
		Button(action: self.action) {
			ZStack {
				if self.isLocked {
					Image(systemName: "lock.fill")
						.font(.footnote)
						.foregroundStyle(Color.mm_text_secondary)
				} else {
					Text("\(self.level)")
						.font(.callout.weight(.bold))
						.foregroundStyle(self.isSelected ? Color.white : Color.mm_text_primary)
				}
			}
			.frame(maxWidth: .infinity, minHeight: 44)
			.background(self.isSelected ? Color.mm_tint_secondary : Color.mm_background_secondary)
			.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
			.overlay(
				RoundedRectangle(cornerRadius: 12, style: .continuous)
					.stroke(self.isSelected ? Color.clear : Color.mm_text_secondary.opacity(0.25), lineWidth: 1)
			)
		}
		.buttonStyle(.plain)
		.disabled(self.isLocked)
		.accessibilityLabel("\(self.level) × \(self.level)")
		.accessibilityAddTraits(self.isSelected ? .isSelected : [])
	}
}

@available(iOS 17.0, *)
#Preview {
	@Previewable @State var currentLevel = 4
	return OptionsLevelSectionView(levels: Array(3...10), maxAchievedLevel: 7, currentLevel: $currentLevel)
		.padding()
		.background(Color.mm_background_secondary)
}
