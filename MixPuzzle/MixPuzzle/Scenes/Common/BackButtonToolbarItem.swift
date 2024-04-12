//
//  BackButtonToolbarItem.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 12.04.2024.
//

import SwiftUI

struct BackButtonToolbarItem: ToolbarContent {
	var action: () -> Void

	var body: some ToolbarContent {
		ToolbarItem(placement: .navigationBarLeading) {
			Button(action: action) {
				Image(systemName: "arrow.left")
					.foregroundColor(Color.mm_tint_primary)
			}
			.buttonStyle(.plain)
		}
	}
}
