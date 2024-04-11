//
//  StartScoreView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 06.04.2024.
//

import SwiftUI

struct StartScoreView: View {
	
	@State var score: Int = 0
	
	@Binding var router: MenuView.Router?
	
    var body: some View {
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
    }
}

#Preview {
	@State var router: MenuView.Router? = nil
    return StartScoreView(router: $router)
}
