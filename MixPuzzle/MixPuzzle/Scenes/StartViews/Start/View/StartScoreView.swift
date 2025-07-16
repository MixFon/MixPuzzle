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
	@State private var hapticTask: Task<Void, Never>? = nil
	@State private var feedbackTimer: Timer?
	@State private var isButtonsDisabled: Bool = false
	@State private var isWigglegHelpButton: Bool = false
	
	@Environment(\.dismiss) var dismiss
	
    var body: some View {
		HStack(spacing: 32) {
			Button {
				self.startSceneDependency.prepareCloseSubject.send()
				self.dismiss()
			} label: {
				SystemImageButton(systemName: "arrow.backward.circle.fill", isWigglegButton: isWigglegHelpButton)
			}
			.buttonStyle(.plain)
			Spacer()
			if self.state == .game {
				Button {
					self.isWigglegHelpButton.toggle()
				} label: {
					SystemImageButton(systemName: "questionmark.circle.fill", isWigglegButton: isWigglegHelpButton)
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
					SystemImageButton(systemName: "list.bullet.circle.fill", isWigglegButton: isWigglegHelpButton)
				}
				.disabled(self.isButtonsDisabled)
				.buttonStyle(.plain)
			}
			if self.state == .game {
				Spacer()
				SystemImageButton(systemName: "arrow.triangle.2.circlepath.circle.fill", isWigglegButton: isWigglegHelpButton)
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
							self.isWigglegHelpButton.toggle()
							self.startSceneDependency.manageShakeAnimationSubject.send(.stop(blendOutDuration: 0.3))
						}
					}
					
			}
		}
		.onReceive(self.startSceneDependency.nodesIsRunningSubject, perform: nodesIsRunningSubjectHandler)
		.animation(.default, value: self.state)
		.padding(.horizontal)
		.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
	
	private func nodesIsRunningSubjectHandler(output: Bool) {
		self.isButtonsDisabled = output
	}

	private func performHapticFeedback() {
		guard hapticTask == nil else { return }
		hapticTask = Task {
			let generator = UIImpactFeedbackGenerator(style: .medium)
			while !Task.isCancelled {
				await MainActor.run {
					generator.prepare()
					generator.impactOccurred()
				}
				try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 секунды
			}
		}
	}

	private func stopContinuousHapticFeedback() {
		hapticTask?.cancel()
		hapticTask = nil
	}
}

struct SystemImageButton: View {
	let systemName: String
	let isWigglegButton: Bool
	var body: some View {
		Image(systemName: self.systemName)
			.resizable()
			.symbolEffectIfAvailable(value: isWigglegButton)
			.frame(width: 32, height: 32)
			.foregroundStyle(Color.mm_tint_icons, Color.mm_background_primary)
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
	
	let startSceneDependency = StartSceneModel()
	VStack {
		StartScoreView(state: .solution, startSceneDependency: startSceneDependency)
		StartScoreView(state: .menu, startSceneDependency: startSceneDependency)
		StartScoreView(state: .game, startSceneDependency: startSceneDependency)
	}
	.padding()
	.background(Color.mm_background_secondary)
}
