//
//  MixButtonStyle.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 25.05.2025.
//

import SwiftUI

struct MixButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.callout)
			.foregroundColor(Color.white)
			.padding(.horizontal, 16)
			.padding(.vertical, 10)
			.background(Color.mm_tint_icons)
			.clipShape(RoundedRectangle(cornerRadius: 12))
			.shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 2)
	}
}
