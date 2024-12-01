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
	@Binding var onClose: Bool
	let dependency: _Dependency
	@ObservedObject var startSceneModel: StartSceneModel
	
	var body: some View {
		ZStack {
			VisualizationSolutionWrapper(matrix: self.matrix, dependency: self.dependency, startSceneModel: self.startSceneModel)
				.equatable()
				.ignoresSafeArea()
			VStack {
				VisualizationSolutionScoreView(onClose: $onClose)
					.padding()
				Spacer()
				VisualizationSolutionPathView(startSceneModel: self.startSceneModel)
					.preferredColorScheme(.dark)
					.background(Color.mm_background_tertiary)
			}
			
		}
	}
}

struct VisualizationSolutionScoreView: View {
	
	@Environment(\.dismiss) private var dismiss
	@Binding var onClose: Bool
	
	var body: some View {
		HStack(spacing: 32) {
			Button {
				self.dismiss()
				self.onClose.toggle()
			} label: {
				ImageButton(systemName: "arrow.backward")
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
	let startSceneModel: StartSceneModel
	
	var body: some View {
		HStack {
			Button {
				let count = self.startSceneModel.compasses.count
				self.startSceneModel.createRange(currentIndex: selectedIndex, selectedIndex: count - 1)
				self.selectedIndex = count - 1
			} label: {
				VisualizationSolutionButton(imageName: "forward.fill", isSelected: false)
			}
			.buttonStyle(.plain)
			ScrollPathView(selectedIndex: $selectedIndex, startSceneModel: self.startSceneModel)
			Button {
				self.startSceneModel.createRange(currentIndex: selectedIndex, selectedIndex: 0)
				self.selectedIndex = 0
			} label: {
				VisualizationSolutionButton(imageName: "backward.fill", isSelected: false)
			}
			.buttonStyle(.plain)
		}
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
	return VisualizationSolutionView(matrix: matrix, onClose: $onClose, dependency: dependency, startSceneModel: startSceneModel)
}
