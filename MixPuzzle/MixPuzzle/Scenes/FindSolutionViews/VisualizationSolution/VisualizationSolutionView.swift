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
	let compasses: [Compass]
	let dependency: _Dependency
	
	@State private var selectedIndex: Int = 0
	let startSceneModel: StartSceneModel = StartSceneModel()
	// 0 1 2 3 4 5 6 7 8
	//   s     e
	//1 2 3 4
	//     e   s
	//
	// 0 1 2 3 4 5 6 7 8
	//       e     s
	// 6 5 4 3
	
    var body: some View {
		VisualizationSolutionWrapper(matrix: self.matrix, dependency: self.dependency, startSceneModel: self.startSceneModel)
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 16) {
				ForEach(self.compasses.indices, id: \.self) { index in
					Button {
						if self.selectedIndex == index { return }
						let start = min(self.selectedIndex, index)
						let end = max(self.selectedIndex, index)
						var range =  Array(self.compasses[start..<end])
						if index < selectedIndex {
							range = range.reversed().map( { $0.opposite } )
						}
						self.selectedIndex = index
						self.startSceneModel.pathSubject.send(range)
					} label: {
						VisualizationSolutionButton(imageName: self.compasses[index].imageName, isSelected: self.selectedIndex == index)
					}
					
				}
			}.padding()
		}
		.padding()
    }
}

#Preview {
	let matrix: Matrix =
	[[1, 2, 3],
	 [4, 5, 6],
	 [7, 0, 8]]
	let compasses: [Compass] = [.north, .west, .north, .east, .east, .south, .south, .south, .west, .west, .north]
	let dependency = MockDependency()
    return VisualizationSolutionView(matrix: matrix, compasses: compasses, dependency: dependency)
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
