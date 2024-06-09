//
//  StartScoreView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 06.04.2024.
//

import SwiftUI

struct StartScoreView: View {
	
	let startSceneDependency: StartSceneModel
	@Binding var showFinishButton: Bool
	@Environment(\.dismiss) var dismiss
	
    var body: some View {
		HStack(spacing: 32) {
			Button {
				self.startSceneDependency.saveSubject.send()
				self.dismiss()
			} label: {
				ImageButton(systemName: "arrow.backward")
			}
			.buttonStyle(.plain)
			Spacer()
			Button {
				
			} label: {
				ImageButton(systemName: "square.grid.3x3.middle.filled")
			}
			.onLongPressGesture(
				perform: {
					
				}, onPressingChanged: { bool in
					print(bool)
					self.startSceneDependency.showSolution.send(bool)
				}
			)
			.buttonStyle(.plain)
			if showFinishButton {
				Spacer()
				Button {
					self.startSceneDependency.finishSubject.send()
				} label: {
					ImageButton(systemName: "flag.checkered")
				}
				.buttonStyle(.plain)
			}
			Spacer()
			Button {
				self.startSceneDependency.regenerateSubject.send()
			} label: {
				ImageButton(systemName: "gobackward")
			}
			.buttonStyle(.plain)
		}
		.animation(.default, value: self.showFinishButton)
		.padding(.horizontal)
		.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct ImageButton: View {
	let systemName: String
	var body: some View {
		Image(systemName: self.systemName)
			.resizable()
			.frame(width: 24, height: 24)
			.foregroundColor(Color.mm_tint_primary)
	}
}

#Preview {
	let startSceneDependency = StartSceneModel()
	@State var isShowFinishButton = true
    return StartScoreView(startSceneDependency: startSceneDependency, showFinishButton: $isShowFinishButton)
}

