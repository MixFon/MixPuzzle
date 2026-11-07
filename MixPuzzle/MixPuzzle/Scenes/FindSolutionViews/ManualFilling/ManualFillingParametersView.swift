//
//  ManualFillingParametersView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 07.11.2026.
//

import SwiftUI
import MFPuzzle

/// Строка параметров в панели: размер поля и цель сборки
struct ManualFillingParametersView: View {
	let sizes: [Int]
	let size: Int
	let onSize: (Int) -> Void
	@Binding var solution: Solution

	var body: some View {
		HStack(spacing: 8) {
			CompactSegmentedPicker(
				items: self.sizes,
				selected: self.size,
				title: { "\($0)×\($0)" },
				onSelect: self.onSize
			)
			.frame(width: 120)
			.accessibilityLabel("mix.manual.size".localized)
			CompactSegmentedPicker(
				items: Solution.allCases,
				selected: self.solution,
				title: { $0.name },
				onSelect: { self.solution = $0 }
			)
			.accessibilityLabel("mix.options.target".localized)
		}
	}
}

/// Компактный сегментный переключатель в стиле вкладок экрана «Куб»
struct CompactSegmentedPicker<Item: Hashable>: View {
	let items: [Item]
	let selected: Item
	let title: (Item) -> String
	let onSelect: (Item) -> Void

	var body: some View {
		HStack(spacing: 2) {
			ForEach(self.items, id: \.self) { item in
				let isSelected = item == self.selected
				Button {
					withAnimation(.easeInOut(duration: 0.2)) {
						self.onSelect(item)
					}
				} label: {
					Text(self.title(item))
						.font(.footnote.weight(isSelected ? .semibold : .regular))
						.foregroundStyle(isSelected ? Color.mm_text_primary : Color.mm_text_secondary)
						.lineLimit(1)
						.minimumScaleFactor(0.7)
						.padding(.horizontal, 2)
						.frame(maxWidth: .infinity, minHeight: 36)
						.background(isSelected ? Color.mm_background_tertiary : Color.clear)
						.clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
				}
				.buttonStyle(.plain)
				.accessibilityAddTraits(isSelected ? .isSelected : [])
			}
		}
		.padding(3)
		.background(Color.mm_background_secondary)
		.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
	}
}

@available(iOS 17.0, *)
#Preview {
	@Previewable @State var size = 4
	@Previewable @State var solution: Solution = .snail
	return ManualFillingParametersView(sizes: [3, 4, 5], size: size, onSize: { size = $0 }, solution: $solution)
		.padding()
		.background(Color.mm_background_tertiary)
}
