//
//  InversionBoardView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 07.11.2026.
//

import SwiftUI
import MFPuzzle

/// Поле для экранов про инверсии: плитки-кубики, подсветка пар,
/// путь обхода «змейкой» поверх поля и, при необходимости, тапы по плиткам.
struct InversionBoardView: View {
	let cells: [MatrixElement]
	let size: Int
	var tileSide: CGFloat = 72
	var spacing: CGFloat = 10
	/// Клетки, подсвеченные оранжевым (например, пара-инверсия)
	var highlighted: Set<Int> = []
	/// Выбранная клетка (акцентная обводка)
	var selected: Int? = nil
	var showsSnake: Bool = false
	/// Тап по плитке. Если `nil`, поле только показывает расстановку.
	var onTap: ((Int) -> Void)? = nil

	var body: some View {
		let step = self.tileSide + self.spacing
		VStack(spacing: self.spacing) {
			ForEach(0..<self.size, id: \.self) { row in
				HStack(spacing: self.spacing) {
					ForEach(0..<self.size, id: \.self) { column in
						self.tile(at: row * self.size + column)
					}
				}
			}
		}
		.overlay(
			SnakePath(size: self.size, step: step, tileSide: self.tileSide)
				.stroke(Color.mm_tint_secondary, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, dash: [2, 8]))
				.opacity(self.showsSnake ? 1 : 0)
				.allowsHitTesting(false)
				.accessibilityHidden(true)
		)
		.animation(.easeInOut(duration: 0.25), value: self.showsSnake)
	}

	@ViewBuilder
	private func tile(at index: Int) -> some View {
		let value = self.cells.indices.contains(index) ? self.cells[index] : 0
		let tile = FillingTileView(value: value, side: self.tileSide, size: self.size, outline: self.outline(for: index))
		if let onTap = self.onTap {
			Button {
				onTap(index)
			} label: {
				tile
			}
			.buttonStyle(.plain)
			.accessibilityLabel(value == 0 ? "mix.manual.cell.blank".localized : "\(value)")
			.accessibilityAddTraits(index == self.selected ? .isSelected : [])
		} else {
			tile
				.accessibilityLabel(value == 0 ? "mix.manual.cell.blank".localized : "\(value)")
		}
	}

	private func outline(for index: Int) -> Color? {
		if index == self.selected {
			return .mm_tint_secondary
		}
		if self.highlighted.contains(index) {
			return .mm_warning
		}
		return nil
	}
}

/// Ломаная через центры клеток в порядке обхода «змейкой»
private struct SnakePath: Shape {
	let size: Int
	let step: CGFloat
	let tileSide: CGFloat

	func path(in rect: CGRect) -> Path {
		var path = Path()
		for (i, index) in InversionMath.order(size: self.size, snake: true).enumerated() {
			let point = CGPoint(
				x: self.tileSide / 2 + CGFloat(index % self.size) * self.step,
				y: self.tileSide / 2 + CGFloat(index / self.size) * self.step
			)
			if i == 0 {
				path.move(to: point)
			} else {
				path.addLine(to: point)
			}
		}
		return path
	}
}

#Preview {
	VStack(spacing: 32) {
		InversionBoardView(cells: [3, 1, 2, 4, 5, 6, 8, 7, 0], size: 3, highlighted: [0, 1])
		InversionBoardView(cells: [3, 1, 2, 4, 5, 6, 8, 7, 0], size: 3, tileSide: 56, showsSnake: true)
	}
	.frame(maxWidth: .infinity, maxHeight: .infinity)
	.background(Color.black)
}
