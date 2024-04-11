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
		Text("Hello, World!")
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
			.navigationTitle("Settings Cubes") // Заголовок для Navigation Bar
			.buttonStyle(.plain)
	}
}

#Preview {
	return SettingsCubeView()
}
