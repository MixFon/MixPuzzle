//
//  SwiftUIView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 23.03.2025.
//

import SwiftUI

struct ContentView: View {
	var body: some View {
		HStack {
			// Левая кнопка
			HStack {
				Button(action: {
					print("Левая кнопка нажата")
				}) {
					Text("Л")
						.padding()
						.background(Color.blue)
						.foregroundColor(.white)
						.cornerRadius(8)
				}
				Spacer()
			}
			.frame(maxWidth: .infinity)

			// Spacer для выравнивания текста по центру
			Spacer()

			// Текст по центру
			Text("Центральный текст")
				.font(.title)
				.padding()

			// Spacer для выравнивания текста по центру
			Spacer()

			// Правая кнопка
			Button(action: {
				print("Правая кнопка нажата")
			}) {
				Text("Правая")
					.frame(maxWidth: .infinity)
					.padding()
					.background(Color.blue)
					.foregroundColor(.white)
					.cornerRadius(8)
			}
		}
		.padding()
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
