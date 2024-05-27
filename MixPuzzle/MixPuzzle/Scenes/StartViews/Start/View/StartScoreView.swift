//
//  StartScoreView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 06.04.2024.
//

import SwiftUI

struct StartScoreView: View {
	
	let startSceneDependency: StartSceneModel
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
			Spacer()
			Button {
				self.startSceneDependency.regenerateSubject.send()
			} label: {
				ImageButton(systemName: "gobackward")
			}
			.buttonStyle(.plain)
		}
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
    return StartScoreView(startSceneDependency: startSceneDependency)
}

