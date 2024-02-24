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
	
	enum Router: Hashable {
		case toStart
        case toOprionts
	}
	
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: Start(), tag: Router.toStart, selection: $router) { EmptyView() }
                NavigationLink(destination: Options(), tag: Router.toOprionts, selection: $router) { EmptyView() }
                MenuScene() { goTo in
                    self.router = goTo
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
