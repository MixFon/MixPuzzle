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
		NavigationView {
			VStack {
				OptionsSectionsView(title: "Garaphics", cells: [
					CellView(icon: "cube", text: "Cube", action: { print(1) }),
					CellView(icon: "moon.stars", text: "Stars", action: { print(2) }),
				])
				.padding()
				Spacer()
			}
			.background(Color.mm_background_secondary)
		}
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button(action: {
					self.router = nil
				}) {
					HStack {
						Image(systemName: "arrow.left") // Кастомная иконка
							.foregroundColor(Color.mm_tint_primary)
					}
				}
				.buttonStyle(.plain)
			}
		}
		.navigationBarBackButtonHidden()
		.navigationTitle("Options") // Заголовок для Navigation Bar
		.buttonStyle(.plain)
	}
}

#Preview {
    @State var router: MenuView.Router? = .toStart
    return OptionsView(router: $router)
}
