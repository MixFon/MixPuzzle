//
//  SettingsGameView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 09.05.2024.
//

import SwiftUI

struct SettingsGameView: View {
    var body: some View {
		VStack {
			NavigationBar(title: "Settings Game", tralingView: AnyView(
				SaveButtonNavigationBar(action: {
					print("Save")
				})
			))
			.padding()
			SelectLevelView()
				.background(Color.mm_background_tertiary)
		}
    }
}

#Preview {
    SettingsGameView()
}
