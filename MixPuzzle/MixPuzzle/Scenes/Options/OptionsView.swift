//
//  OptionsView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 24.02.2024.
//

import SwiftUI

struct OptionsView: View {
	
	@State private var toBox: Bool = false
	@State private var toStars: Bool = false
	@State private var toLanguage: Bool = false
	@State private var toVibration: Bool = false
	@State private var isOnVibration: Bool = false
	
	var body: some View {
		VStack {
			NavigationBar(title: "Options")
				.padding()
			OptionsSectionsView(title: "Garaphics", cells: [
				AnyView(CellView(icon: "cube", text: "Cube", action: { self.toBox = true })),
				AnyView(CellView(icon: "moon.stars", text: "Stars", action: { self.toStars = true })),
			])
			.padding()
			OptionsSectionsView(title: "Application", cells: [
				AnyView(CellView(icon: "globe", text: "Language", action: { self.toLanguage = true })),
				AnyView(ToggleCellView(icon: "waveform.path", text: "Vibration", isOn: $isOnVibration)),
			])
			.padding()
			Spacer()
		}
		.background(Color.mm_background_secondary)
		.fullScreenCover(isPresented: self.$toBox) {
			SettingsCubeView()
		}
		.fullScreenCover(isPresented: self.$toStars) {
			SettingsCubeView()
		}
	}
}

#Preview {
	OptionsView()
}
