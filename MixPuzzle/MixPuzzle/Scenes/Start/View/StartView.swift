//
//  StartView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 22.02.2024.
//

import SwiftUI
import MFPuzzle

struct StartView: View {

    @Binding var router: MenuView.Router?
	
    var body: some View {
		ZStack {
			StartSceneWrapper(router: $router)
				.equatable() // Отключение обновления сцены
			VStack {
				StartScoreView(router: $router)
				Spacer()
			}
			.navigationBarBackButtonHidden()
		}
    }
}

#Preview {
    @State var router: MenuView.Router? = nil
    return StartView(router: $router)
}
