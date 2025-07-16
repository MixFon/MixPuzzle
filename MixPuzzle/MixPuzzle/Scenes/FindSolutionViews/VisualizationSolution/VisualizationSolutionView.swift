//
//  VisualizationSolutionView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 01.06.2024.
//

import SwiftUI
import MFPuzzle

struct VisualizationSolutionView: View {
	let matrix: Matrix
	let dependency: _Dependency
	@ObservedObject var startSceneModel: StartSceneModel
	
	var body: some View {
		ZStack {
			VisualizationSolutionWrapper(matrix: self.matrix, dependency: self.dependency, startSceneModel: self.startSceneModel)
				.id("solution_static_id")
				.ignoresSafeArea()
			VStack {
				VisualizationSolutionScoreView()
					.padding()
				Spacer()
				VisualizationSolutionPathView(startSceneModel: self.startSceneModel)
			}
		}
	}
}

struct VisualizationSolutionScoreView: View {
	
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		HStack(spacing: 32) {
			Button {
				self.dismiss()
			} label: {
				SystemImageButton(systemName: "arrow.backward.circle.fill", isWigglegButton: true)
			}
			.buttonStyle(.plain)
			Spacer()
		}
		.padding(.horizontal)
		.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
	}
}

struct VisualizationSolutionPathView: View {
	@State private var selectedIndex: Int = 0
	@State private var isDesable: Bool = false
	let startSceneModel: StartSceneModel
	
	var body: some View {
		HStack {
			Button {
				self.startSceneModel.deleteAllAnimationFromNodeSubject.send()
				let count = self.startSceneModel.compasses.count
				self.startSceneModel.createRange(currentIndex: self.selectedIndex, selectedIndex: count - 1)
				self.selectedIndex = count - 1
			} label: {
				VisualizationSolutionButton(imageName: "forward.fill", isSelected: false)
					.scaleEffect(!self.isDesable ? 1 : 0.8)
					.animation(.spring(response: 0.3, dampingFraction: 0.2), value: !self.isDesable)
			}
			.buttonStyle(.plain)
			ScrollPathView(selectedIndex: $selectedIndex, startSceneModel: self.startSceneModel)
			Button {
				self.startSceneModel.deleteAllAnimationFromNodeSubject.send()
				self.startSceneModel.createRange(currentIndex: self.selectedIndex, selectedIndex: 0)
				self.selectedIndex = 0
			} label: {
				VisualizationSolutionButton(imageName: "backward.fill", isSelected: false)
					.scaleEffect(!self.isDesable ? 1 : 0.8)
					.animation(.spring(response: 0.3, dampingFraction: 0.2), value: !self.isDesable)
			
			}
			.buttonStyle(.plain)
		}
		.preferredColorScheme(.dark)
		.background(Color.mm_background_tertiary.opacity(0.3))
		.clipShape(RoundedRectangle(cornerRadius: 24))
		.onReceive(self.startSceneModel.disablePathButtonsViewSubject, perform: { isDisable in
			self.isDesable = isDisable
		})
		.disabled(isDesable)
	}
	
}


struct VisualizationSolutionButton: View {
	let imageName: String
	let isSelected: Bool
	
	var body: some View {
		Image(systemName: imageName)
			.resizable()
			.clipped()
			.scaledToFit()
			.frame(width: 32, height: 32)
			.clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
			.shadow(radius: 5)
			.padding()
			.overlay(
				RoundedRectangle(cornerRadius: 10)
					.stroke(Color.blue, lineWidth: self.isSelected  ? 4 : 0)
			)
	}
}

struct ScrollPathView: View {
	@Binding var selectedIndex: Int
	let startSceneModel: StartSceneModel
	
	var body: some View {
		ScrollViewReader { scrollViewProxy in
			ScrollView(.horizontal, showsIndicators: false) {
				HStack(spacing: 0) {
					ForEach(self.startSceneModel.compasses.indices, id: \.self) { index in
						Button {
							if self.selectedIndex == index { return }
							self.startSceneModel.createRange(currentIndex: self.selectedIndex, selectedIndex: index)
							self.selectedIndex = index
						} label: {
							VStack {
								VisualizationSolutionButton(imageName: self.startSceneModel.compasses[index].imageName, isSelected: self.selectedIndex == index)
									.scaleEffect(self.selectedIndex == index ? 1 : 0.8)
									.animation(.spring(response: 0.3, dampingFraction: 0.2), value: self.selectedIndex == index)
								Text("\(index + 1)")
									.font(.caption)
									.foregroundStyle(Color.mm_text_primary)
							}
						}
						.buttonStyle(.plain)
						.id(index)
					}
				}
				.padding(4)
			}
			.frame(height: 100)
			.onChange(of: self.selectedIndex, perform: { value in
				withAnimation {
					scrollViewProxy.scrollTo(value, anchor: .center)
				}
			})
		}
	}
}

@available(iOS 17.0, *)
#Preview {
	@Previewable @State var onClose = true
	let matrix: Matrix =
	[[1, 2, 3],
	 [4, 5, 6],
	 [7, 0, 8]]
	let compasses: [Compass] = [.north, .west, .north, .east, .east, .south, .south, .south, .west, .west, .north]
	let dependency = MockDependency()
	@ObservedObject var startSceneModel = StartSceneModel()
	startSceneModel.compasses = compasses
	return VisualizationSolutionView(matrix: matrix, dependency: dependency, startSceneModel: startSceneModel)
}
