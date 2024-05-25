//
//  Snackbar.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 30.04.2024.
//

import SwiftUI

final class MMSnackbarModel: ObservableObject {
	@Published var text: String = ""
	@Published var style: MMSnackbarStyle = .success
	@Published var isShowing: Bool = false
}

public enum MMSnackbarStyle {
	case error
	case warning
	case success
	
	var foregroundColor: Color {
		switch self {
		case .error:
			return Color.mm_danger
		case .success:
			return Color.mm_green
		case .warning:
			return Color.mm_warning
		}
	}
	
	var icon: Image {
		switch self {
		case .error:
			return Image(systemName: "xmark.circle.fill")
		case .success:
			return Image(systemName: "checkmark.circle.fill")
		case .warning:
			return Image(systemName: "exclamationmark.circle.fill")
		}
	}
}

@available(iOS 14.0, *)
internal struct MMSnackbar: View {
	
	@Binding
	var isShowing: Bool
	
	private let presenting: AnyView
	private let text: Text
	private let style: MMSnackbarStyle
	private let extraBottomPadding: CGFloat
	private let dismissOnTap: Bool
	private let dismissAfter: Double?
	
	internal init<Presenting>(isShowing: Binding<Bool>, presenting: Presenting, text: Text, style: MMSnackbarStyle, extraBottomPadding: CGFloat, actionText: String? = nil, action: (() -> Void)? = nil, dismissOnTap: Bool = true, dismissAfter: Double? = 4) where Presenting: View {
		_isShowing = isShowing
		self.presenting = AnyView(presenting)
		self.text = text
		self.style = style
		self.extraBottomPadding = extraBottomPadding
		self.dismissOnTap = dismissOnTap
		self.dismissAfter = dismissAfter
	}
	
	internal init<Presenting>(isShowing: Binding<Bool>, presenting: Presenting, text: String, style: MMSnackbarStyle, extraBottomPadding: CGFloat, dismissOnTap: Bool = true, dismissAfter: Double? = 4) where Presenting: View {
		_isShowing = isShowing
		self.presenting = AnyView(presenting)
		self.text = Text(text)
		self.style = style
		self.extraBottomPadding = extraBottomPadding
		self.dismissOnTap = dismissOnTap
		self.dismissAfter = dismissAfter
	}
	
	internal var body: some View {
		ZStack {
			presenting
			VStack {
				Spacer()
				snackbar
			}
		}
	}
	
	private var snackbar: some View {
		VStack(alignment: .leading) {
			Spacer()
			if isShowing {
				HStack {
					self.style.icon
						.resizable()
						.frame(width: 24, height: 24)
						.foregroundColor(self.style.foregroundColor)
					self.text
						.font(.system(.body, design: .rounded))
						.foregroundColor(.mm_background_primary)
						.frame(maxWidth: .infinity, alignment: .leading)
				}
				.padding()
				.background(Color.mm_tint_primary)
				.transition(.move(edge: .bottom))
				.onAppear {
					if let dismissAfter = dismissAfter {
						DispatchQueue.main.asyncAfter(deadline: .now() + dismissAfter) {
							withAnimation {
								self.isShowing = false
							}
						}
					}
				}
				.onTapGesture {
					if dismissOnTap {
						isShowing = false
					}
				}
				.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
			}
		}
		.opacity(isShowing ? 1 : 0)
		.padding(.horizontal)
		.padding(.bottom, extraBottomPadding)
	}
}
