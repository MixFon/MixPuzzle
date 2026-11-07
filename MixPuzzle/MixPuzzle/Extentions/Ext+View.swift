//
//  Ext+View.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 30.04.2024.
//

import SwiftUI

extension View {
	
	// Модификатор для окраничения ввода количества символов в String
	func limitedText(_ text: Binding<String>, to limit: Int) -> some View {
		self.modifier(LimitedTextField(text: text, limit: limit))
	}
	
	@ViewBuilder
	func symbolEffectIfAvailable<U: Equatable>(value: U) -> some View {
		if #available(iOS 18.0, *) {
			self.symbolEffect(.wiggle, options: .default, value: value)
		} else {
			self
		}
	}
}
