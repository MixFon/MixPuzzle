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
		Text("Hello, World!")
			.toolbar {
				BackButtonToolbarItem {
					self.presentationMode.wrappedValue.dismiss()
				}
			}
			.navigationBarBackButtonHidden()
			.navigationTitle("Settings Cubes")
			.buttonStyle(.plain)
	}
}

#Preview {
	return SettingsCubeView()
}
