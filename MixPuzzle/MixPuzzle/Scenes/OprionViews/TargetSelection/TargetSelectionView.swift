//
//  TargetSelectionView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 17.05.2024.
//

import SwiftUI
import MFPuzzle

struct TargetSelectionView: View {
	let dependncy: _Dependency
	
	@State private var isShowSnackbar = false
    var body: some View {
		VStack {
			NavigationBar(title: "Target selection", tralingView: AnyView(
				SaveButtonNavigationBar(action: {
					//self.model.saveChanges()
					self.isShowSnackbar = true
				})
			))
			.padding()
			ForEach(matrixes, id: \.hashValue) { matrix in
				Button {
					
				} label: {
					TargetSelectSceneWrapper(matrix: matrix, dependency: self.dependncy)
						.aspectRatio(contentMode: .fit)
						.clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
				}
			}
		}
		.snackbar(isShowing: $isShowSnackbar, text: "The data has been saved successfully.", style: .success, extraBottomPadding: 16)
    }
	
	private var matrixes: [Matrix] {
		let classic: Matrix = [
			[1, 2, 3],
			[4, 5, 6],
			[7, 8, 0],
		]
		let snake: Matrix = [
			[1, 2, 3],
			[6, 5, 4],
			[7, 8, 0],
		]
		let spiral: Matrix = [
			[1, 2, 3],
			[8, 0, 4],
			[7, 6, 5],
		]
		return [classic, snake, spiral]
	}
}

#Preview {
	let mockDependecy = MockDependency()
    return TargetSelectionView(dependncy: mockDependecy)
}
