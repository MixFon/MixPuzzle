//
//  NavigationBar.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 16.04.2024.
//

import SwiftUI

struct NavigationBar: View {
	var title: String
	var tralingView: AnyView?
	
	var body: some View {
		HStack {
			ZStack {
				HStack{
					BackButtonNavigationBar()
					Spacer()
					self.tralingView
				}
				Text(title)
					.font(.headline)
					.fontWeight(.semibold)
					.foregroundStyle(Color.mm_text_primary)
			}
		}
	}
}

struct BackButtonNavigationBar: View {
	
	@Environment(\.presentationMode)
	private var presentationMode: Binding<PresentationMode>
	
	var body: some View {
		Button {
			self.presentationMode.wrappedValue.dismiss()
		} label: {
			Image(systemName: "arrow.left")
				.resizable()
				.scaledToFit()
				.frame(width: 24, height: 24)
				.foregroundColor(Color.mm_tint_primary)
				.aspectRatio(contentMode: .fit)
		}
		.buttonStyle(.plain)
	}
	
}

#Preview {
	VStack {
		NavigationBar(title: "Hello")
		NavigationBar(title: "Hello", tralingView: AnyView(Text("Hello")))
	}
}
