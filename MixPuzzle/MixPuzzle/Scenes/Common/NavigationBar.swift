//
//  NavigationBar.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 16.04.2024.
//

import SwiftUI

struct NavigationBar: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	var title: String
	
	var body: some View {
		HStack {
			ZStack {
				HStack{
					Button {
						self.presentationMode.wrappedValue.dismiss()
					} label: {
						Image(systemName: "arrow.left")
							.foregroundColor(Color.mm_tint_primary)
							.aspectRatio(contentMode: .fit)
					}
					.buttonStyle(.plain)
					Spacer()
				}
				Text(title)
					.font(.title3)
					.fontWeight(.regular)
					.foregroundStyle(Color.mm_text_primary)
			}
		}
		.padding()
		.background(Color.mm_background_tertiary) // Цвет фона
	}
}

#Preview {
	VStack {
		NavigationBar(title: "Hello")
	}
}
