//
//  StartView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 22.02.2024.
//

import SwiftUI
import MFPuzzle

struct StartView: View {
	
	@State var score: Int = 0

    @Binding var router: MenuView.Router?
	
    var body: some View {
		ZStack {
			StartSceneWrapper(router: $router)
				.equatable() // Отключение обновления сцены
			VStack {
				HStack {
					Text("Hello\(score)")
						.foregroundColor(Color.red)
					Text("Hello_1")
						.foregroundColor(Color.red)
					Button {
						self.score += 1
					} label: {
						Text("Press me")
					}
					Button {
						self.router = nil
					} label: {
						Text("Go back")
					}
				}
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
