//
//  OptionsView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 24.02.2024.
//

import SwiftUI

struct OptionsView: View {
	
	@State private var optionsRouter: OptionsViewRouter? = nil
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	
	enum OptionsViewRouter: Hashable {
		case toBox
		case toStars
		case toLanguage
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
				OptionsSectionsView(title: "Application", cells: [
					CellView(icon: "globe", text: "Language", action: { optionsRouter = .toLanguage }),
				])
				.padding()
				Spacer()
			}
			.background(Color.mm_background_secondary)
		}
		.toolbar {
			BackButtonToolbarItem {
				self.presentationMode.wrappedValue.dismiss()
			}
		}
		.navigationBarBackButtonHidden()
		.navigationTitle("Options")
		.buttonStyle(.plain)
	}
}

#Preview {
    return OptionsView()
}
