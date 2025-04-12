//
//  TargetSelectionView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 17.05.2024.
//

import SwiftUI
import MFPuzzle

final class TargetSelectionModel: ObservableObject {
	@Published var selectedSolution: Solution
	
	private var gameWorker: _GameWorker
	
	init(gameWorker: _GameWorker) {
		self.gameWorker = gameWorker
		self.selectedSolution = gameWorker.solution
	}
	
	func saveChanges() {
		self.gameWorker.save(solution: self.selectedSolution)
	}
}

struct TargetSelectionView: View {
	private let dependncy: _Dependency
	private let solutionOptions: [MatrixSolution]
	
	@ObservedObject
	private var model: TargetSelectionModel
	@StateObject
	private var startSceneModel = StartSceneModel()
	private let startSelectedMatrix: Matrix
	
	@State
	private var isShowSnackbar = false
	
	private let title = String(localized: "Targets", comment: "Title for Target selection screen")
	private let smackbarSavedMessage = String(localized: "mix.snackbar.saved", comment: "Message for snackbar when saved")
	
	init(dependncy: _Dependency) {
		self.dependncy = dependncy
		let gameWorker = dependncy.workers.gameWorker
		self.startSelectedMatrix = gameWorker.solutionOptions.first(where: {$0.type == gameWorker.solution})?.matrix ?? Matrix()
		self.solutionOptions = self.dependncy.workers.gameWorker.solutionOptions
		self.model = TargetSelectionModel(gameWorker: gameWorker)
	}
	
    var body: some View {
		VStack {
			NavigationBar(
				title: self.title,
				tralingView: AnyView(
					SaveButtonNavigationBar(
						action: {
							self.model.saveChanges()
							self.isShowSnackbar = true
						}
					)
				)
			)
			.padding()
			TargetSelectSceneWrapper(matrix: self.startSelectedMatrix, dependency: dependncy, startSceneModel: self.startSceneModel)
				.clipShape(RoundedRectangle(cornerRadius: 24))
				.aspectRatio(contentMode: .fit)
				.padding(.horizontal)
			SelectSizePicker(selectedSize: self.$model.selectedSolution, numbersSize: solutionOptions.map({$0.type}))
				.padding()
			Spacer()
		}
		.onChange(of: self.model.selectedSolution, perform: { value in
			if let matrix = self.solutionOptions.first(where: {$0.type == value})?.matrix {
				self.startSceneModel.showMatrixSubject.send(matrix)
			}
		})
		.snackbar(isShowing: $isShowSnackbar, text: self.smackbarSavedMessage, style: .success, extraBottomPadding: 16)
		.background(Color.mm_background_tertiary)
    }
}

struct TargetView: View {
	let option: MatrixSolution
	let dependncy: _Dependency
	let isSelected: Bool
	
	private let radius: CGFloat = 24
	var body: some View {
		VStack {
			
			Text(option.type.name)
				.padding()
				.clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
				.overlay(
					RoundedRectangle(cornerRadius: radius)
						.stroke(isSelected ? Color.blue : Color.gray, lineWidth: 3)
				)
		}
	}
}

#Preview {
	let mockDependecy = MockDependency()
	return TargetSelectionView(dependncy: mockDependecy)
}

