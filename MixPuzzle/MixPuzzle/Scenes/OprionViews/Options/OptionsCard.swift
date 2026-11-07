//
//  OptionsCard.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 07.11.2026.
//

import SwiftUI

/// Карточка-секция экрана настроек со скруглёнными углами
struct OptionsCard<Content: View>: View {
	@ViewBuilder let content: Content

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			self.content
		}
		.padding(16)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(Color.mm_background_tertiary)
		.clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
	}
}

#Preview {
	OptionsCard {
		Text("Title")
			.font(.headline)
		Text("Content")
			.foregroundStyle(Color.mm_text_secondary)
	}
	.padding()
	.background(Color.mm_background_secondary)
}
