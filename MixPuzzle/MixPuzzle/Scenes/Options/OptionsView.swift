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
	@State private var toBox: Bool = false
	
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
					AnyView(CellView(icon: "cube", text: "Cube", action: { toBox = true })),
					AnyView(CellView(icon: "moon.stars", text: "Stars", action: { self.presentationMode.wrappedValue.dismiss() })),
				])
				.padding()
				OptionsSectionsView(title: "Application", cells: [
					AnyView(CellView(icon: "globe", text: "Language", action: { optionsRouter = .toLanguage })),
					AnyView(CellView(icon: "waveform.path", text: "Vibration", action: { optionsRouter = .toLanguage })),
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
		.fullScreenCover(isPresented: $toBox) {
			SettingsCubeView()
		}
		.navigationBarBackButtonHidden()
		.navigationTitle("Options")
		.buttonStyle(.plain)
	}
}

#Preview {
	NavigationView {
		OptionsView()
	}
}
