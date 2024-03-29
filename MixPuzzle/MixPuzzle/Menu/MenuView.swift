//
//  ContentView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 20.02.2024.
//

import SwiftUI
import SceneKit
import MFPuzzle

struct MenuView: View {
    
    private let size = 4
    private let matrixWorker = MatrixWorker()

    @State private var router: Router? = nil
	
	enum Router: Hashable {
		case toStart
        case toOprionts
	}
	
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: StartView(router: $router), tag: Router.toStart, selection: $router) { }
                NavigationLink(destination: OptionsView(router: $router), tag: Router.toOprionts, selection: $router) { }
//                StartScene(worker: BoxesWorker(size: self.size, matrixWorker: self.matrixWorker), complition: {_ in
//                    
//                })
//                MenuScene() { goTo in
//                    self.router = goTo
//                }
            }
        }
    }
}

#Preview {
    MenuView()
}
