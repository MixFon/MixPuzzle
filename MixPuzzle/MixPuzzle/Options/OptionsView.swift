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
		OptionsSectionsView(title: "Two", cells: [
			CellView(icon: "plus", text: "Hello", action: { print(1) }),
			CellView(icon: "checkmark", text: "word", action: { print(2) }),
			CellView(icon: "checkmark", text: "text text", action: { print(2) }),
		])
		.padding()
		Spacer()
	}
}


struct OptionsSectionsView: View {
	let title: String
	let cells: [CellView]
	
	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text(title)
				.bold()
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
		Button(action: action, label: {
			HStack {
				Image(systemName: icon)
					.buttonStyle(.plain)
				Text(text)
				Spacer()
				Image(systemName: "chevron.right")
					.foregroundColor(.black) // Цвет шеврона
			}
		})
		.buttonStyle(.plain)
	}
}

#Preview {
    @State var router: MenuView.Router? = .toStart
    return OptionsView(router: $router)
}
