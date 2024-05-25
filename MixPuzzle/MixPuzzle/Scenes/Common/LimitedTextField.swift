//
//  LimitedTextField.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 25.05.2024.
//

import SwiftUI

// Создаем модификатор для ограничения длины текста
struct LimitedTextField: ViewModifier {
	@Binding var text: String
	
	var limit: Int
	
	func body(content: Content) -> some View {
		content
			.onChange(of: text) { newValue in
				if newValue.count > limit {
					text = String(newValue.prefix(limit))
				}
			}
	}
}
