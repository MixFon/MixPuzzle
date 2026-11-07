//
//  ManualFillingBoardView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 07.11.2026.
//

import SwiftUI
import MFPuzzle

/// Поле ручного ввода: плитки в стиле кубиков игры, тап выбирает клетку.
/// Размер плиток подстраивается под доступное место (поле растёт, когда панель свёрнута).
struct ManualFillingBoardView: View {
	let size: Int
	let cells: [MatrixElement?]
	let selectedIndex: Int
	/// Клетки с повторяющимися значениями — красная обводка
	var errorIndices: Set<Int> = []
	/// Клетки, которые предлагается поменять местами, — оранжевая обводка
	var highlightedIndices: Set<Int> = []
	let onSelect: (Int) -> Void

	private let spacing: CGFloat = 8

	var body: some View {
		GeometryReader { geometry in
			let side = self.tileSide(in: geometry.size)
			VStack(spacing: self.spacing) {
				ForEach(0..<self.size, id: \.self) { row in
					HStack(spacing: self.spacing) {
						ForEach(0..<self.size, id: \.self) { column in
							let index = row * self.size + column
							Button {
								self.onSelect(index)
							} label: {
								FillingTileView(
									value: self.cells.indices.contains(index) ? self.cells[index] : nil,
									side: side,
									size: self.size,
									outline: self.outline(for: index)
								)
							}
							.buttonStyle(.plain)
							.accessibilityLabel(self.accessibilityLabel(for: index))
							.accessibilityAddTraits(index == self.selectedIndex ? .isSelected : [])
						}
					}
				}
			}
			.frame(width: geometry.size.width, height: geometry.size.height)
		}
	}

	/// Плитки квадратные, не больше 90 pt и не меньше 24 pt
	private func tileSide(in available: CGSize) -> CGFloat {
		let count = CGFloat(self.size)
		let gaps = self.spacing * (count - 1)
		let side = min((available.width - gaps) / count, (available.height - gaps) / count)
		return min(max(side, 24), 90)
	}

	private func outline(for index: Int) -> Color? {
		if self.errorIndices.contains(index) {
			return .mm_danger
		}
		if self.highlightedIndices.contains(index) {
			return .mm_warning
		}
		if index == self.selectedIndex {
			return .mm_tint_secondary
		}
		return nil
	}

	private func accessibilityLabel(for index: Int) -> String {
		let value = self.cells.indices.contains(index) ? self.cells[index] : nil
		let state: String
		switch value {
		case .none:
			state = "mix.manual.cell.unfilled".localized
		case .some(0):
			state = "mix.manual.cell.blank".localized
		case .some(let number):
			state = "\(number)"
		}
		return String(format: "mix.manual.cell".localized, index + 1, state)
	}
}

/// Одна плитка поля
private struct FillingTileView: View {
	let value: MatrixElement?
	let side: CGFloat
	let size: Int
	let outline: Color?

	/// Цвета плитки как у кубиков по умолчанию (текстура Terrazzo)
	private static let tileColor = Color(hex: "D8D2C6") ?? .gray
	private static let numberColor = Color(hex: "2F7DE1") ?? .blue

	private var cornerRadius: CGFloat { self.side * 0.18 }

	var body: some View {
		ZStack {
			switch self.value {
			case .none:
				// Ещё не заполнена
				RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous)
					.fill(Color.white.opacity(0.04))
					.overlay(
						RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous)
							.strokeBorder(Color.mm_text_secondary.opacity(0.6), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
					)
				Text("?")
					.font(.system(size: self.side * 0.3, weight: .semibold))
					.foregroundStyle(Color.mm_text_secondary)
			case .some(0):
				// Пустая клетка пятнашек
				RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous)
					.fill(Color.white.opacity(0.06))
					.overlay(
						RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous)
							.strokeBorder(Color.mm_text_secondary.opacity(0.4), lineWidth: 1.5)
					)
				Text("mix.manual.blank.short".localized)
					.font(.system(size: max(9, self.side * 0.15), weight: .semibold))
					.foregroundStyle(Color.mm_text_secondary)
					.lineLimit(1)
					.minimumScaleFactor(0.6)
					.padding(.horizontal, 4)
			case .some(let number):
				RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous)
					.fill(Self.tileColor)
					.shadow(color: .black.opacity(0.5), radius: 9, x: 0, y: 8)
				Circle()
					.fill(Color.white)
					.frame(width: self.side * 0.64, height: self.side * 0.64)
				Text("\(number)")
					.font(.system(size: self.side * 0.34, weight: .heavy, design: .rounded))
					.foregroundStyle(self.outline == .mm_danger ? Color.mm_danger : Self.numberColor)
					.minimumScaleFactor(0.5)
			}
		}
		.frame(width: self.side, height: self.side)
		.overlay(
			RoundedRectangle(cornerRadius: self.cornerRadius + 4, style: .continuous)
				.stroke(self.outline ?? .clear, lineWidth: 3)
				.padding(-4)
		)
		.contentShape(Rectangle())
		.animation(.easeOut(duration: 0.15), value: self.value)
	}
}

#Preview {
	ManualFillingBoardView(
		size: 4,
		cells: [5, 1, 3, 4, 2, 6, nil, 8, 9, 10, 7, 12, nil, 13, 13, 0],
		selectedIndex: 6,
		errorIndices: [13, 14],
		onSelect: { debugPrint($0) }
	)
	.padding()
	.background(Color.black)
}
