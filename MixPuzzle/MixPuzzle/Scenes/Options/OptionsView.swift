//
//  OptionsView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 24.02.2024.
//

import SwiftUI

struct OptionsView: View {
	
	@State var optionsRouter: OptionsViewRouter? = nil
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	
	enum OptionsViewRouter: Hashable {
		case toBox
		case toStars
	}
	
	var body: some View {
		ZStack {
			NavigationLink(destination: SettingsCubeView(), tag: OptionsViewRouter.toBox, selection: $optionsRouter) { }
			VStack {
				OptionsSectionsView(title: "Garaphics", cells: [
					CellView(icon: "cube", text: "Cube", action: { optionsRouter = .toBox }),
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
					self.presentationMode.wrappedValue.dismiss()
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
    return OptionsView()
}
