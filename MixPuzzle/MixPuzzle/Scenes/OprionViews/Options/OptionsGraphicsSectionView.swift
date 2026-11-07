//
//  OptionsGraphicsSectionView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 07.11.2026.
//

import SwiftUI

/// Секция с плитками перехода к настройкам графики
struct OptionsGraphicsSectionView: View {
	let cubeSubtitle: String
	let asteroidsSubtitle: String
	let lightSubtitle: String
	let onCube: () -> Void
	let onAsteroids: () -> Void
	let onLight: () -> Void

	private let cube = String(localized: "Cube", comment: "Name of cell in options screen")
	private let asteroids = String(localized: "Asteroids", comment: "Name of cell in options screen")
	private let lighting = String(localized: "Lighting")

	var body: some View {
		HStack(spacing: 10) {
			GraphicsTile(icon: "cube", title: self.cube, subtitle: self.cubeSubtitle, action: self.onCube)
			GraphicsTile(icon: "moon.stars", title: self.asteroids, subtitle: self.asteroidsSubtitle, action: self.onAsteroids)
			GraphicsTile(icon: "lightbulb.max", title: self.lighting, subtitle: self.lightSubtitle, action: self.onLight)
		}
	}
}

/// Плитка перехода к настройкам графики
private struct GraphicsTile: View {
	let icon: String
	let title: String
	let subtitle: String
	let action: () -> Void

	var body: some View {
		Button(action: self.action) {
			VStack(alignment: .leading, spacing: 0) {
				Image(systemName: self.icon)
					.font(.title2)
					.foregroundStyle(Color.mm_tint_secondary)
				Spacer(minLength: 12)
				Text(self.title)
					.font(.subheadline.weight(.semibold))
					.foregroundStyle(Color.mm_text_primary)
					.lineLimit(1)
					.minimumScaleFactor(0.8)
				Text(self.subtitle)
					.font(.caption)
					.foregroundStyle(Color.mm_text_secondary)
					.lineLimit(1)
			}
			.padding(.horizontal, 12)
			.padding(.vertical, 14)
			.frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
			.background(Color.mm_background_tertiary)
			.clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
		}
		.buttonStyle(.plain)
	}
}

#Preview {
	OptionsGraphicsSectionView(
		cubeSubtitle: "Terrazzo Slab",
		asteroidsSubtitle: "200",
		lightSubtitle: "Spot",
		onCube: { debugPrint("cube") },
		onAsteroids: { debugPrint("asteroids") },
		onLight: { debugPrint("light") }
	)
	.padding()
	.background(Color.mm_background_secondary)
}
