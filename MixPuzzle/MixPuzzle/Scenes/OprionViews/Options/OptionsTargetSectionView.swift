//
//  OptionsTargetSectionView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 07.11.2026.
//

import SwiftUI
import MFPuzzle

/// Секция выбора целевой раскладки
struct OptionsTargetSectionView: View {
	@Binding var solution: Solution

	private let title = String(localized: "mix.options.target", comment: "Title of target section in options")

	var body: some View {
		OptionsCard {
			Text(self.title)
				.font(.headline)
				.foregroundStyle(Color.mm_text_primary)
			HStack(spacing: 10) {
				ForEach(Solution.displayOrder, id: \.self) { solution in
					TargetCard(solution: solution, isSelected: solution == self.solution) {
						self.solution = solution
					}
				}
			}
			Text(self.solution.localizedDescription)
				.font(.footnote)
				.foregroundStyle(Color.mm_text_secondary)
				.fixedSize(horizontal: false, vertical: true)
		}
	}
}

/// Карточка целевой раскладки с мини-схемой 3×3
private struct TargetCard: View {
	let solution: Solution
	let isSelected: Bool
	let action: () -> Void

	var body: some View {
		Button(action: self.action) {
			VStack(spacing: 8) {
				LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 3), spacing: 3) {
					ForEach(Array(self.solution.previewCells.enumerated()), id: \.offset) { _, value in
						self.cell(value)
					}
				}
				Text(self.solution.name)
					.font(.caption.weight(.semibold))
					.foregroundStyle(Color.mm_text_primary)
					.lineLimit(1)
					.minimumScaleFactor(0.7)
			}
			.padding(10)
			.background(Color.mm_background_secondary)
			.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
			.overlay(
				RoundedRectangle(cornerRadius: 16, style: .continuous)
					.stroke(self.isSelected ? Color.mm_tint_secondary : Color.mm_text_secondary.opacity(0.25), lineWidth: 2)
			)
		}
		.buttonStyle(.plain)
		.accessibilityAddTraits(self.isSelected ? .isSelected : [])
	}

	@ViewBuilder
	private func cell(_ value: Int) -> some View {
		if value == 0 {
			RoundedRectangle(cornerRadius: 5, style: .continuous)
				.strokeBorder(Color.mm_text_secondary.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [3]))
				.aspectRatio(1, contentMode: .fit)
		} else {
			RoundedRectangle(cornerRadius: 5, style: .continuous)
				.fill(self.isSelected ? Color.mm_text_primary : Color.mm_text_secondary.opacity(0.3))
				.aspectRatio(1, contentMode: .fit)
				.overlay(
					Text("\(value)")
						.font(.system(size: 11, weight: .bold))
						.foregroundStyle(self.isSelected ? Color.mm_background_tertiary : Color.mm_text_primary)
				)
		}
	}
}

private extension Solution {
	/// Порядок карточек на экране
	static let displayOrder: [Solution] = [.classic, .snail, .boustrophedon]

	/// Схема 3×3 для превью (0 — пустая клетка)
	var previewCells: [Int] {
		switch self {
		case .classic:
			return [1, 2, 3, 4, 5, 6, 7, 8, 0]
		case .snail:
			return [1, 2, 3, 8, 0, 4, 7, 6, 5]
		case .boustrophedon:
			return [1, 2, 3, 6, 5, 4, 7, 8, 0]
		}
	}

	var localizedDescription: String {
		switch self {
		case .snail:
			return "mix.description.solution.snail".localized
		case .classic:
			return "mix.description.solution.classic".localized
		case .boustrophedon:
			return "mix.description.solution.boustrophedon".localized
		}
	}
}

@available(iOS 17.0, *)
#Preview {
	@Previewable @State var solution: Solution = .snail
	return OptionsTargetSectionView(solution: $solution)
		.padding()
		.background(Color.mm_background_secondary)
}
