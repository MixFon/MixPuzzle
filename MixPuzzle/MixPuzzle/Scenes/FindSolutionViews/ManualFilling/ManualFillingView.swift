//
//  ManualFillingView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 25.05.2024.
//

import SwiftUI
import MFPuzzle

final class ManualFillingRouter: ObservableObject {
	@Published var toLoading = false
	@Published var toInversion = false
	@Published var toVisualizationSolution = false
}
	
struct ManualFillingView: View {
	private let dependency: _Dependency
	private let numbersSize = Array(3...5)
	private let possibleSolution: [Solution] = Solution.allCases
	
	@State private var matrix: [[String]] = [
		["1", "3", "5"],
		["2", "4", "6"],
		["8", "7", ""],
	]
	@State private var selectedSize = 3
	@State private var selectedSolution: Solution = .classic
	@State private var isShowSnackbar = false
	
	@StateObject private var router = ManualFillingRouter()
	@StateObject private var startSceneModel = StartSceneModel()
	@StateObject private var snackbarModel = MMSnackbarModel()
	
	@State private var fillingMatrix: Matrix = [[]]
	@State private var matrixSolution: Matrix = [[]]
	
	init(dependency: _Dependency) {
		self.dependency = dependency
	}

	var body: some View {
		VStack {
			NavigationBar(title: "Manual filling".localized, tralingView: AnyView(
				SaveButtonNavigationBar(action: {
					checkMatrix()
				})
			))
			.padding()
			ScrollView {
				VStack(spacing: 8) {
					SelectSizePicker(selectedSize: $selectedSolution, numbersSize: possibleSolution)
					SelectSizePicker(selectedSize: $selectedSize, numbersSize: numbersSize)
					buttonsView()
				}
				FillingMatrixView(matrix: $matrix)
					.padding()
			}
			Spacer()
		}
		.onChange(of: selectedSize, perform: { value in
			updateMatrix(size: value)
		})
		.onChange(of: selectedSize, perform: { value in
			updateMatrix(size: value)
		})
		.snackbar(isShowing: self.$snackbarModel.isShowing, text: self.snackbarModel.text, style: self.snackbarModel.style, extraBottomPadding: 16)
		.fullScreenCover(isPresented: $router.toLoading, onDismiss: { self.router.toVisualizationSolution = !self.startSceneModel.compasses.isEmpty }) {
			LoadingView(matrix: fillingMatrix, puzzle: self.dependency.createPuzzle(), matrixTarger: matrixSolution) { compasses in
				self.startSceneModel.compasses = compasses ?? []
				self.router.toLoading = false
			}
		}
		.fullScreenCover(isPresented: $router.toVisualizationSolution) {
			VisualizationSolutionView(matrix: fillingMatrix, dependency: dependency, startSceneModel: self.startSceneModel)
		}
		.fullScreenCover(isPresented: $router.toInversion) {
			VisualizationSolutionView(matrix: fillingMatrix, dependency: dependency, startSceneModel: self.startSceneModel)
		}
		.background(Color.mm_background_secondary)
	}
	
	private func buttonsView() -> some View {
		HStack {
			Button {
				regenerateMatrix()
			} label: {
				Image.mix_icon_restart
					.resizable()
					.frame(width: 64, height: 64)
			}
			.frame(maxWidth: .infinity)
			Button {
				regenerateMatrix()
			} label: {
				Image.mix_icon_info
					.resizable()
					.frame(width: 64, height: 64)
			}
			.frame(maxWidth: .infinity)
		}
	}
	
	private func regenerateMatrix() {
		var randomMatrix = self.dependency.workers.matrixWorker.createMatrixRandom(size: self.selectedSize)
		let matrixSolution = self.dependency.workers.matrixWorker.createMatrixSolution(size: self.selectedSize, solution: self.selectedSolution)
		if !self.dependency.checker.checkSolution(matrix: randomMatrix, matrixTarget: matrixSolution) {
			self.dependency.workers.matrixWorker.changesParityInvariant(matrix: &randomMatrix)
		}
		self.matrix = convertMatrixToString(matrix: randomMatrix)
		updateMatrix(size: self.matrix.count)
	}
	
	private func convertMatrixToString(matrix: Matrix) -> [[String]] {
		var newMatrix = Array(repeating: Array(repeating: "", count: matrix.count), count: matrix.count)
		for (i, zipElem) in zip(newMatrix, matrix).enumerated() {
			for (j, elem) in zip(zipElem.0, zipElem.1).enumerated() {
				newMatrix[i][j] = String(elem.1)
			}
		}
		return newMatrix
	}

	private func updateMatrix(size: Int) {
		var newMatrix = Array(repeating: Array(repeating: "", count: size), count: size)
		for (i, zipElem) in zip(newMatrix, self.matrix).enumerated() {
			for (j, elem) in zip(zipElem.0, zipElem.1).enumerated() {
				newMatrix[i][j] = elem.1
			}
		}
		self.matrix = newMatrix
	}
	
	/// Создается матрица из MatrixElement и проверяется Cheker
	private func checkMatrix() {
		let size = matrix.count
		var matrixDigit: Matrix = Array(repeating: Array(repeating: MatrixElement(0), count: size), count: size)
		let matrixSolution = self.dependency.workers.matrixWorker.createMatrixSolution(size: size, solution: self.selectedSolution)
		for (i, row) in self.matrix.enumerated() {
			for (j, elem) in row.enumerated() {
				matrixDigit[i][j] = MatrixElement(elem) ?? 0
			}
		}
		if !self.dependency.checker.checkUniqueElementsMatrix(matrix: matrixDigit) {
			showSnackbarError()
		} else if !self.dependency.checker.checkSolution(matrix: matrixDigit, matrixTarget: matrixSolution) {
			showSnackbarErrorNotSolution()
		} else {
			showSnackbarSuccesee(fillingMatrix: matrixDigit, matrixSolution: matrixSolution)
		}
	}
	
	/// Показывает ошибки правильности заполнения матрицы.
	private func showSnackbarError() {
		let maxMatrixElemetn = self.selectedSize * self.selectedSize - 1
		self.snackbarModel.text = String(format: NSLocalizedString("mix.snackbar.matrix.fill.incorrectly", comment: ""), maxMatrixElemetn)
		self.snackbarModel.style = .error
		self.snackbarModel.isShowing = true
	}
	
	private func showSnackbarErrorNotSolution() {
		let solutionName = self.selectedSolution.name
		self.snackbarModel.text = String(format: NSLocalizedString("mix.snackbar.matrix.not.solution", comment: ""), solutionName)
		self.snackbarModel.style = .error
		self.snackbarModel.isShowing = true
	}
	
	private func showSnackbarSuccesee(fillingMatrix: Matrix, matrixSolution: Matrix) {
		self.fillingMatrix = fillingMatrix
		self.matrixSolution = matrixSolution
		self.router.toLoading = true
	}
}

struct FillingMatrixView: View {
	
	@Binding var matrix: [[String]]
	
	var body: some View {
		VStack(spacing: 20) {
			ForEach(0..<matrix.count, id: \.self) { row in
				HStack(spacing: 20) {
					ForEach(0..<matrix.count, id: \.self) { column in
						FillingMatrixElementView(text: $matrix[row][column])
					}
				}
			}
		}
	}
}

struct FillingMatrixElementView: View {
	@Binding var text: String
	private let cornerRadius: CGFloat = 8
	
	var body: some View {
		TextField("0", text: $text)
			.frame(width: 50, height: 50)
			.keyboardType(.numberPad)
			.multilineTextAlignment(.center)
			.foregroundColor(Color.mm_text_primary)
			.background(Color.mm_background_tertiary)
			.clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
			.limitedText($text, to: 2)
			.overlay(
				RoundedRectangle(cornerRadius: cornerRadius)
					.stroke(Color.mm_divider_opaque, lineWidth: 2)
			)
	}
}

struct SelectSizePicker<T: Hashable & CustomStringConvertible>: View {
	@Binding var selectedSize: T
	let numbersSize: [T]
	
	var body: some View {
		Picker("Choose the size", selection: $selectedSize) {
			ForEach(numbersSize, id: \.self) { size in
				Text("\(size.description)").tag(size)
			}
		}
		.pickerStyle(SegmentedPickerStyle())
	}
}

#Preview {
	let dependency = MockDependency()
	return ManualFillingView(dependency: dependency)
}
