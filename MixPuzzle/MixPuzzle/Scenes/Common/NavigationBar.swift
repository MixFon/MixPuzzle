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
			HStack {
				BackButtonNavigationBar()
				Spacer()
			}
			.frame(maxWidth: .infinity)
			Text(title)
				.font(.headline)
				.fontWeight(.semibold)
				.multilineTextAlignment(.center)
				.foregroundStyle(Color.mm_text_primary)
			HStack {
				Spacer()
				self.tralingView
			}
			.frame(maxWidth: .infinity)
		}
	}
}

struct BackButtonNavigationBar: View {
	
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		Button {
			self.dismiss()
		} label: {
			Image(systemName: "arrow.left")
				.resizable()
				.scaledToFit()
				.frame(width: 20, height: 20)
				.foregroundColor(Color.mm_tint_primary)
				.aspectRatio(contentMode: .fit)
		}
		.buttonStyle(.plain)
	}
}

struct SaveButtonNavigationBar: View {
    var action: ()->()
    var body: some View {
        Button(action: action, label: {
            Text("Save")
                .font(.callout)
                .foregroundStyle(Color.mm_text_primary)
        })
		.buttonStyle(.plain)
    }
}

#Preview {
	VStack {
		NavigationBar(title: "Hello")
		NavigationBar(title: "Hello", tralingView: AnyView(Text("Hello")))
        NavigationBar(title: "Hello Settinfs sdfsdf", tralingView: AnyView(SaveButtonNavigationBar(action: {debugPrint("Save")})))
	}
}
