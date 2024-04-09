//
//  OptionsSectionsView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 09.04.2024.
//

import SwiftUI
import Foundation

struct OptionsSectionsView: View {
	let title: String
	let cells: [CellView]
	
	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text(title)
				.font(.title2)
				.bold()
				.foregroundStyle(Color.mm_text_primary)
			VStack(spacing: 8) {
				ForEach(cells.indices, id: \.self) { index in
					self.cells[index]
					if index != self.cells.indices.last {
						DividerView()
					}
				}
			}
		}
		.padding(20)
		.background(Color.mm_background_tertiary)
		.cornerRadius(16)
	}
}

struct CellView: View, Identifiable {
	let id = UUID()
	let icon: String
	let text: String
	let action: ()->()
	
	var body: some View {
		Button(action: action, label: {
			HStack {
				Image(systemName: icon)
					.buttonStyle(.plain)
					.foregroundStyle(Color.mm_text_primary)
				Text(text)
					.foregroundStyle(Color.mm_text_primary)
				Spacer()
				Image(systemName: "chevron.right")
					.foregroundStyle(Color.mm_text_primary)
			}
		})
		.buttonStyle(.plain)
	}
}


struct DividerView: View {
	var body: some View {
		Divider()
			.padding(.leading, 30)
			.foregroundColor(Color.mm_text_secondary)
	}
}

#Preview {
	VStack {
		OptionsSectionsView(title: "Hello", cells: [
			CellView(icon: "plus", text: "Hello", action: { print(1) }),
			CellView(icon: "checkmark", text: "word", action: { print(2) }),
		])
		.padding()
		OptionsSectionsView(title: "Two", cells: [
			CellView(icon: "plus", text: "Hello", action: { print(1) }),
			CellView(icon: "checkmark", text: "word", action: { print(2) }),
			CellView(icon: "checkmark", text: "text text", action: { print(2) }),
		])
		.padding()
		Spacer()
	}
	.background(Color.mm_background_secondary)
}
