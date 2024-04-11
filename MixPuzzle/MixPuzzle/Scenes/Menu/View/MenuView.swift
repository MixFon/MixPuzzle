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
			ZStack {
				NavigationLink(destination: StartView(router: $router), tag: Router.toStart, selection: $router) { }
				NavigationLink(destination: OptionsView(), tag: Router.toOprionts, selection: $router) { }
				MenuSceneWrapper(router: $router)
			}
			.edgesIgnoringSafeArea(.all)
		}
		.navigationBarBackButtonHidden()
	}
}

#Preview {
    MenuView()
}
