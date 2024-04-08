//
//  OptionsView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 24.02.2024.
//

import SwiftUI

struct OptionsView: View {
	
    @Binding var router: MenuView.Router?
	
	enum OptionsViewRouter: Codable {
		case to
	}
	
	var body: some View {
		OptionsSectionsView(title: "Hello", cells: [
			CellView(icon: "plus", text: "Hello", action: { print(1) }),
			CellView(icon: "checkmark", text: "word", action: { print(2) }),
		])
		.padding()
		OptionsSectionsView(title: "Hello", cells: [
			CellView(icon: "plus", text: "Hello", action: { print(1) }),
			CellView(icon: "checkmark", text: "word", action: { print(2) }),
		])
	}
}


struct OptionsSectionsView: View {
	let title: String
	let cells: [CellView]
	
	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text("123")
			VStack(spacing: 8) {
				ForEach(cells) { cell in
					cell
					Divider()
						.padding(.leading, 30)
				}
			}
		}
		.padding()
		.background(.gray)
		.cornerRadius(16)
	}
}

struct CellView: View, Identifiable {
	let id = UUID()
	let icon: String
	let text: String
	let action: ()->()
	
	var body: some View {
		HStack {
			Image(systemName: icon)
			Button(action: action, label: {
				Text(text)
			})
			.buttonStyle(.plain)
			Spacer()
			Image(systemName: "chevron.right")
				.foregroundColor(.green) // Цвет шеврона
		}
	}
}

#Preview {
    @State var router: MenuView.Router? = .toStart
    return OptionsView(router: $router)
}
