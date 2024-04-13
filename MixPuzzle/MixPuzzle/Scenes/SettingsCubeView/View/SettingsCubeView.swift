//
//  SettingsCubeView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 11.04.2024.
//

import SwiftUI

struct SettingsCubeView: View {
	
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	
    var body: some View {
		SettingsCubeWrapper()
			.aspectRatio(contentMode: .fit)
			.cornerRadius(10)
			.padding()
			.background(Color.mm_background_tertiary)
		Button("Button") {
			print("pressme")
		}
		Text("Hello, World!")
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
}

#Preview {
	SettingsCubeView()
}
