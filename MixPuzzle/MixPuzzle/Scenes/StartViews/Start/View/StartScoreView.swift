//
//  StartScoreView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 06.04.2024.
//

import SwiftUI

struct StartScoreView: View {
	
	var state: StartState
	let startSceneDependency: StartSceneModel
	private let generator = UIImpactFeedbackGenerator(style: .light)
	@State private var feedbackTimer: Timer?
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
			if self.state == .game {
				Button {
					
				} label: {
					ImageButton(systemName: "square.grid.3x3.middle.filled")
				}
				.onLongPressGesture(
					perform: {
						
					}, onPressingChanged: { bool in
						self.startSceneDependency.showSolution.send(bool)
					}
				)
				.buttonStyle(.plain)
			}
			if self.state == .solution {
				Spacer()
				Button {
					self.startSceneDependency.showMenuSubject.send()
				} label: {
					ImageButton(systemName: "flag.checkered")
				}
				.buttonStyle(.plain)
			}
			if self.state == .game {
				Spacer()
				ImageButton(systemName: "gobackward")
					.onLongPressGesture(minimumDuration: 1.5) {
						print("Long pressed!")
						self.startSceneDependency.regenerateSubject.send()
						stopContinuousHapticFeedback()
						self.startSceneDependency.manageShakeAnimationSubject.send(false)
					} onPressingChanged: { inProgress in
						self.startSceneDependency.manageShakeAnimationSubject.send(inProgress)
						if inProgress {
							performHapticFeedback()
						} else {
							stopContinuousHapticFeedback()
						}
					}
			}
		}
		.animation(.default, value: self.state)
		.padding(.horizontal)
		.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
	
	private func performHapticFeedback() {
		guard feedbackTimer == nil else { return }
		feedbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
			generator.prepare()
			generator.impactOccurred()
		}
	}
	
	private func stopContinuousHapticFeedback() {
		feedbackTimer?.invalidate()
		feedbackTimer = nil
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

@available(iOS 17.0, *)
#Preview {
	@Previewable @State var state = StartState.game
	let startSceneDependency = StartSceneModel()
	return StartScoreView(state: state, startSceneDependency: startSceneDependency)
}
