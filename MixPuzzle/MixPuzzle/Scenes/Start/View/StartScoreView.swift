//
//  StartScoreView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 06.04.2024.
//

import SwiftUI

struct StartScoreView: View {
	
	@State var score: Int = 0
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	
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
				self.presentationMode.wrappedValue.dismiss()
			} label: {
				Text("Go back")
			}
		}
    }
}

#Preview {
    return StartScoreView()
}
