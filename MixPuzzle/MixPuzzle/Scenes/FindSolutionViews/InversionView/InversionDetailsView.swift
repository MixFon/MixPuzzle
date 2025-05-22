//
//  InversionDetailsView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 22.05.2025.
//

import SwiftUI
import MFPuzzle

final class InversionDetailsViewModel: ObservableObject {
	let checker: _Checker
	let matrixWorker: _MatrixWorker
	@Published var stack: [(Int, Int)] = []
	@Published var matrix: Matrix = []
	@Published var pointsInversion: [(Point, Point)] = []
	
	@Published var selectedSize = 3
	
	let numbersSize = Array(3...5)

	init(checker: _Checker, matrixWorker: _MatrixWorker) {
		self.checker = checker
		self.matrixWorker = matrixWorker
		self.stack = generateSnakeStack(n: self.selectedSize)
	}
	
	func calrutateInversions() {
		self.matrix = self.matrixWorker.createMatrixRandom(size: self.selectedSize)
		let inversion = self.checker.getCoupleInversion(matrix: matrix)
		self.pointsInversion = inversion.map({ (Point(row: Int($0.0.x), collomn: Int($0.0.y)), Point(row: Int($0.1.x), collomn: Int($0.1.y)))})
		self.stack = generateSnakeStack(n: self.selectedSize)
	}
	
	private func generateSnakeStack(n: Int) -> [(Int, Int)] {
		let matrix = (0..<n).map { i in
			let row = (0..<n).map { j in i * n + j }
			return i % 2 == 0 ? row : row.reversed()
		}

		let arr = matrix.flatMap { $0 }

		return (1..<arr.count).map { i in (arr[i - 1], arr[i]) }
	}
}

struct InversionDetailsView: View {
	@StateObject var viewModel: InversionDetailsViewModel

    var body: some View {
		VStack {
			NavigationBar(title: "Inversions".localized, tralingView: nil)
				.padding(.horizontal)
				.padding(.top)
			ScrollView {
				VStack(spacing: 8) {
					SelectSizePicker(selectedSize: $viewModel.selectedSize, numbersSize: viewModel.numbersSize)
				}
				MatrixView(
					stack: viewModel.stack,
					matrix: viewModel.matrix,
					pointsInversion: viewModel.pointsInversion
				)
			}
			Spacer()
		}
		.onChange(of: viewModel.selectedSize, perform: { value in
			viewModel.calrutateInversions()
		})
		.onAppear {
			viewModel.calrutateInversions()
		}
		.background(Color.mm_background_secondary)
    }
}

#Preview {
	InversionDetailsView(viewModel: InversionDetailsViewModel(checker: MockChecker(), matrixWorker: MockMatrixWorker()))
}
