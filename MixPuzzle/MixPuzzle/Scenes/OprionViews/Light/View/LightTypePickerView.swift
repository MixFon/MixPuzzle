//
//  LightTypePickerView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 07.11.2026.
//

import SwiftUI

/// Выбор типа источника света карточками 2×2
struct LightTypePickerView: View {
	@Binding var selected: LightType
	var types: [LightType] = LightType.allCases

	var body: some View {
		LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
			ForEach(self.types, id: \.self) { type in
				LightTypeCard(type: type, isSelected: type == self.selected) {
					withAnimation(.easeInOut(duration: 0.2)) {
						self.selected = type
					}
				}
			}
		}
	}
}

/// Карточка типа света: иконка, название и короткое описание
private struct LightTypeCard: View {
	let type: LightType
	let isSelected: Bool
	let action: () -> Void

	var body: some View {
		Button(action: self.action) {
			VStack(alignment: .leading, spacing: 6) {
				Image(systemName: self.type.iconName)
					.font(.title3)
					.foregroundStyle(self.isSelected ? Color.mm_tint_secondary : Color.mm_text_secondary)
					.frame(height: 28)
				Text(self.type.localizedName)
					.font(.subheadline.weight(.semibold))
					.foregroundStyle(Color.mm_text_primary)
					.lineLimit(1)
					.minimumScaleFactor(0.8)
				Text(self.type.localizedHint)
					.font(.caption)
					.foregroundStyle(Color.mm_text_secondary)
					.lineLimit(2)
					.multilineTextAlignment(.leading)
					// Резервируем две строки, чтобы карточки были одной высоты (reservesSpace — только iOS 16+)
					.frame(minHeight: 32, alignment: .topLeading)
			}
			.padding(12)
			.frame(maxWidth: .infinity, alignment: .leading)
			.background(Color.mm_background_secondary)
			.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
			.overlay(
				RoundedRectangle(cornerRadius: 16, style: .continuous)
					.stroke(self.isSelected ? Color.mm_tint_secondary : Color.clear, lineWidth: 2)
			)
		}
		.buttonStyle(.plain)
		.accessibilityAddTraits(self.isSelected ? .isSelected : [])
	}
}

extension LightType {
	/// Название типа света для интерфейса
	var localizedName: String {
		switch self {
		case .spot:
			return String(localized: "mix.light.type.spot", comment: "Spot light type name")
		case .omni:
			return String(localized: "mix.light.type.omni", comment: "Omni light type name")
		case .ambient:
			return String(localized: "mix.light.type.ambient", comment: "Ambient light type name")
		case .directional:
			return String(localized: "mix.light.type.directional", comment: "Directional light type name")
		case .undefined:
			return self.description
		}
	}

	/// Короткое пояснение под названием
	fileprivate var localizedHint: String {
		switch self {
		case .spot:
			return String(localized: "mix.light.type.spot.hint", comment: "Spot light type hint")
		case .omni:
			return String(localized: "mix.light.type.omni.hint", comment: "Omni light type hint")
		case .ambient:
			return String(localized: "mix.light.type.ambient.hint", comment: "Ambient light type hint")
		case .directional:
			return String(localized: "mix.light.type.directional.hint", comment: "Directional light type hint")
		case .undefined:
			return ""
		}
	}

	fileprivate var iconName: String {
		switch self {
		case .spot:
			return "flashlight.on.fill"
		case .omni:
			return "lightbulb.fill"
		case .ambient:
			return "sun.haze.fill"
		case .directional:
			return "sun.max.fill"
		case .undefined:
			return "questionmark"
		}
	}
}

@available(iOS 17.0, *)
#Preview {
	@Previewable @State var selected: LightType = .spot
	return LightTypePickerView(selected: $selected)
		.padding()
		.background(Color.mm_background_tertiary)
}
