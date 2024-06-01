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
	
    var body: some View {
        Text("sdf")
		
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 16) {
				ForEach(self.compasses, id: \.self) { compass in
					Button {
						
					} label: {
						Text("s")
					}
					
				}
			}
		}
		.padding()
    }
}

#Preview {
	let matrix: Matrix =
	[[1, 2, 3],
	 [4, 5, 6],
	 [7, 0, 8]]
	let compasses: [Compass] = [.north, .west, .north, .east, .east, .south, .south]
	let dependency = MockDependency()
    return VisualizationSolutionView(matrix: matrix, compasses: compasses, dependency: dependency)
}
