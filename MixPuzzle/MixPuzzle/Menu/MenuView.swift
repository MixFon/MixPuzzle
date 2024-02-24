//
//  ContentView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 20.02.2024.
//

import SwiftUI
import SceneKit

struct MenuView: View {
	
	@State private var router: Router? = nil
	
	enum Router: Hashable {
		case toStart
        case toOprionts
	}
	
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: StartView(router: $router), tag: Router.toStart, selection: $router) { EmptyView() }
                NavigationLink(destination: OptionsView(router: $router), tag: Router.toOprionts, selection: $router) { EmptyView() }
                MenuScene() { goTo in
                    self.router = goTo
                }
            }
        }
    }
}

#Preview {
    MenuView()
}
