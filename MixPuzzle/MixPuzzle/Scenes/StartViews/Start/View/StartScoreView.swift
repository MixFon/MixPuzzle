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
	@State private var isButtonsDisabled: Bool = false
	@Environment(\.dismiss) var dismiss
	
    var body: some View {
		HStack(spacing: 32) {
			Button {
				self.startSceneDependency.prepareCloseSubject.send()
				self.dismiss()
			} label: {
				AssetsImageButton(image: .mix_icon_close)
			}
			.buttonStyle(.plain)
			Spacer()
			if self.state == .game {
				Button {
					
				} label: {
					AssetsImageButton(image: .mix_icon_help)
				}
				.onLongPressGesture(
					perform: {
						
					}, onPressingChanged: { bool in
						self.startSceneDependency.showSolution.send(bool)
					}
				)
				.disabled(self.isButtonsDisabled)
				.buttonStyle(.plain)
			}
			if self.state == .solution {
				Spacer()
				Button {
					self.startSceneDependency.deleteAllAnimationFromNodeSubject.send()
					self.startSceneDependency.showMenuSubject.send()
				} label: {
					AssetsImageButton(image: .mix_icon_menu)
				}
				.disabled(self.isButtonsDisabled)
				.buttonStyle(.plain)
			}
			if self.state == .game {
				Spacer()
				AssetsImageButton(image: .mix_icon_updates)
					.opacity(self.isButtonsDisabled ? 0.4 : 1)
					.allowsHitTesting(!self.isButtonsDisabled)
					.onLongPressGesture(minimumDuration: 0.5) {
						stopContinuousHapticFeedback()
						self.startSceneDependency.manageShakeAnimationSubject.send(.stop(blendOutDuration: nil))
						self.startSceneDependency.regenerateSubject.send()
					} onPressingChanged: { inProgress in
						if inProgress {
							performHapticFeedback()
							self.startSceneDependency.manageShakeAnimationSubject.send(.start)
						} else {
							stopContinuousHapticFeedback()
							self.startSceneDependency.manageShakeAnimationSubject.send(.stop(blendOutDuration: 0.3))
						}
					}
					
			}
		}
		.onReceive(self.startSceneDependency.nodesIsRunningSubject, perform: { output in
			self.isButtonsDisabled = output
		})
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

struct SystemImageButton: View {
	let systemName: String
	var body: some View {
		Image(systemName: self.systemName)
			.resizable()
			.frame(width: 24, height: 24)
			.foregroundColor(Color.mm_tint_primary)
	}
}

struct AssetsImageButton: View {
	let image: Image
	var body: some View {
		self.image
			.resizable()
			.frame(width: 48, height: 48)
	}
}

@available(iOS 17.0, *)
#Preview {
	@Previewable @State var state = StartState.game
	let startSceneDependency = StartSceneModel()
	return StartScoreView(state: state, startSceneDependency: startSceneDependency)
}
