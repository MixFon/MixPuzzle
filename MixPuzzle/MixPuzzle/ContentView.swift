//
//  ContentView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 20.02.2024.
//

import SwiftUI
import SceneKit

struct ContentView: View {
	
	@State private var router: Router? = nil
	@State private var selection: String? = nil
	
	enum Router: Hashable {
		case toStart
	}
	
    var body: some View {
		NavigationLink(destination: Start(), tag: Router.toStart, selection: $router) { EmptyView() }
		NavigationLink(destination: Start(), tag: "View2", selection: $selection) { EmptyView() }
		MenuScene(router: $router)
		Button("Show View 1") {
			self.router = .toStart
		}
		Button("Show View 2") {
			self.selection = "View2"
		}
    }
}

#Preview {
    ContentView()
}
