//
//  Ext+View.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 30.04.2024.
//

import SwiftUI

extension View {
	/// Adds a snackbar to the view
	///
	/// - Parameters:
	///   - isShowing: Binding that lets you control the `show` state of the `Snackbar`
	///   - title: The bolder text on top
	///   - text: The body text
	///   - style: The style of the `Snackbar`, changing this will change the background color
	///   - actionText: The text of the action button (optional)
	///   - extraBottomPadding: The additional padding from the bottom of the view (optional)
	///   - action: The action you want to perform when the user touches the action button (optional)
	///   - dismissOnTap: if the user can dismiss the `Snackbar` by tapping it, defaults to true
	///   - dismissAfter: how long should the `Snackbar` be displayed on the screen (in seconds)  defaults to 4, set it to `nil` to make it never dismiss itself
	/// - Note: for usage information consider reading the `README.md` on the [Github]() page
	///
	/// You can use the other view extension (The one with both `title` and `text` as `Text`) to further customize the text apparence
	///
	/// - Version: 0.1
	@available(iOS 14.0, *)
	func snackbar(isShowing: Binding<Bool>, text: String = "Как дела?", style: MMSnackbarStyle, dismissOnTap: Bool = true, dismissAfter: Double? = 4, extraBottomPadding: CGFloat = 0) -> some View {
		MMSnackbar(isShowing: isShowing, presenting: self, text: text, style: style, extraBottomPadding: extraBottomPadding, dismissOnTap: dismissOnTap, dismissAfter: dismissAfter)
	}
	
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
