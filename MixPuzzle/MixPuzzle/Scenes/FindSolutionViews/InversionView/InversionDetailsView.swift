//
//  InversionDetailsView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 22.05.2025.
//

import SwiftUI
import MFPuzzle

struct InversionDetailsView: View {
	
	@State private var matrix: Matrix
	@State private var firstPoint: Point?
	@State private var selectedSize: Int
	@State private var secondPoint: Point?
	@State private var isRunAnimation: Bool = false
	private let checker: _Checker
	private let matrixWorker: _MatrixWorker
	init(checker: _Checker, matrixWorker: _MatrixWorker) {
		let selectedSize = 3
		self.selectedSize = selectedSize
		self.matrix = matrixWorker.createMatrixRandom(size: selectedSize)
		self.checker = checker
		self.matrixWorker = matrixWorker
	}
	
	private let numbersSize = Array(3...5)

    var body: some View {
		VStack {
			NavigationBar(title: "Inversions".localized, tralingView: nil)
				.padding(.horizontal)
				.padding(.top)
			SelectSizePicker(selectedSize: $selectedSize, numbersSize: numbersSize)
				.disabled(self.isRunAnimation)
				.padding()
			buttonViews
			MatrixView(
				matrix: self.$matrix,
				firstPoint: self.$firstPoint,
				secoldPoint: self.$secondPoint,
				isRunAnimation: self.$isRunAnimation,
				checker: self.checker
			)
			.padding(.horizontal)
			Spacer()
		}
		.onChange(of: self.selectedSize, perform: { newValue in
			self.matrix = self.matrixWorker.createMatrixRandom(size: newValue)
		})
		.background(Color.mm_background_secondary)
    }
	
	private var buttonViews: some View {
		HStack {
			Button("Parity of inversions") {
				swapInversions(matrix: &self.matrix)
			}
			.buttonStyle(MixButtonStyle())
			.frame(maxWidth: .infinity, alignment: .center)
			Button("Move zero") {
				swapZeroAndNeighbor(matrix: &self.matrix)
			}
			.buttonStyle(MixButtonStyle())
			.frame(maxWidth: .infinity, alignment: .center)
		}
		.disabled(self.isRunAnimation)
		.opacity(self.isRunAnimation ? 0.5 : 1)
	}
	
	private func swapInversions(matrix: inout Matrix) {
		let randomI = Int.random(in: 0..<matrix.count)
		let randomJ = Int.random(in: 0..<matrix.count)
		if self.matrix[randomI][randomJ] == 0 {
			swapInversions(matrix: &matrix)
			return
		}
		let randomPoint = Point(row: randomI, collomn: randomJ)
		let neighborCoordinates = getNeighbor(point: randomPoint, matrix: matrix)
		self.firstPoint = randomPoint
		self.secondPoint = neighborCoordinates
		swapValues(in: &matrix, first: randomPoint, second: neighborCoordinates)
	}
	
	private func swapZeroAndNeighbor(matrix: inout Matrix) {
		if let zeroCoordinates = getZeroCoordinates(from: matrix) {
			let neighborCoordinates = getNeighbor(point: zeroCoordinates, matrix: matrix)
			self.firstPoint = zeroCoordinates
			self.secondPoint = neighborCoordinates
			swapValues(in: &matrix, first: zeroCoordinates, second: neighborCoordinates)
		}
	}
	
	private func getZeroCoordinates(from matrix: Matrix) -> Point? {
		for (i, row) in matrix.enumerated() {
			for (j, value) in row.enumerated() {
				if value == 0 {
					return Point(row: i, collomn: j)
				}
			}
		}
		return nil
	}
	
	private func checkInMatrix(point: Point, matrix: Matrix) -> Bool {
		return point.row >= 0 && point.row < matrix.count && point.collomn >= 0 && point.collomn < matrix.count
	}
	
	private func getNeighbor(point: Point, matrix: Matrix) -> Point {
		if isRandomBool {
			// По первому элементу
			let coor = Point(row: point.row + (isRandomBool ? 1 : -1),collomn:  point.collomn)
			if checkInMatrix(point: coor, matrix: matrix) {
				return coor
			} else {
				return getNeighbor(point: point, matrix: matrix)
			}
		} else {
			// По второму элементу
			let coor = Point(row: point.row, collomn: point.collomn + (isRandomBool ? 1 : -1))
			if checkInMatrix(point: coor, matrix: matrix) {
				return coor
			} else {
				return getNeighbor(point: point, matrix: matrix)
			}
		}
	}

	private var isRandomBool: Bool {
		Int.random(in: 0...1) == 0
	}
	
	private func swapValues(in matrix: inout Matrix, first: Point, second: Point) {
		(matrix[first.row][first.collomn], matrix[second.row][second.collomn]) = (matrix[second.row][second.collomn], matrix[first.row][first.collomn])
	}
}

#Preview {
	InversionDetailsView(checker: MockChecker(), matrixWorker: MockMatrixWorker())
}
