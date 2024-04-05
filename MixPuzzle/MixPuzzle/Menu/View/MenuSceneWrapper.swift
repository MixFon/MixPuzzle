//
//  MenuViewWrapper.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 05.04.2024.
//

import SwiftUI

struct MenuSceneWrapper: View {
	
	@Binding var router: MenuView.Router?

    var body: some View {
		MenuScene() { goTo in
			self.router = goTo
		}
    }
}

extension MenuSceneWrapper: Equatable {
	static func == (lhs: MenuSceneWrapper, rhs: MenuSceneWrapper) -> Bool {
		return true
	}
}

#Preview {
	@State var router: MenuView.Router? = nil
    return MenuSceneWrapper(router: $router)
}
