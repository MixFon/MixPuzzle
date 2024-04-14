//
//  SettingsCubeView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 11.04.2024.
//

import SwiftUI

class SettingsCubeDependency: ObservableObject {
	@Published var radius: Double = 10
}

struct SettingsCubeView: View {
	
	@ObservedObject var dependecy: SettingsCubeDependency = SettingsCubeDependency()
	
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	//@State var radius: Double = 1.0
	
	var body: some View {
		VStack {
			SettingsCubeWrapper(dependency: dependecy)
				.aspectRatio(contentMode: .fit)
				.cornerRadius(10)
				.padding()
				.background(Color.mm_background_secondary)
			OptionsSectionsView(title: "Cube", cells: [
				AnyView(SliderCellView(title: "Radius", range: 0...30, radius: $dependecy.radius)),
			])
			.padding()
			.toolbar {
				BackButtonToolbarItem {
					self.presentationMode.wrappedValue.dismiss()
				}
			}
			.navigationBarBackButtonHidden()
			.navigationTitle("Settings Cubes")
			.buttonStyle(.plain)
			Spacer()
		}
		.background(Color.mm_background_secondary)
	}
}

#Preview {
	SettingsCubeView()
}
