//
//  Path.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 13.05.2025.
//

import SwiftUI
import MFPuzzle

// View должна принимать матрицу. Отобразить ее. Показать путь обзода змейкой
// Почередно выделять красным инварианты, выделенные элементы записать ниже.
// Показать итоговую четность инвариантов

struct Point: Equatable {
	let row: Int
	let collomn: Int
}

struct MatrixView: View {
	
	@Binding var matrix: Matrix
	@Binding var firstPoint: Point?
	@Binding var secoldPoint: Point?
	@Binding var isRunAnimation: Bool
	let checker: _Checker
	
	private let cellSize: CGFloat = 50
	private let spacing: CGFloat = 10
	private var size: Int {
		self.matrix.count
	}
	
	@State
	private var parity: String?

	@State
	private var pointOne: Point?
	@State
	private var pointTwo: Point?
	

	@State
	private var currentCountInversion: Int = 0
	@State
	private var inversions: [String] = []

	// Пары точек для соединения (индексы ячеек: строка * size + столбец)
	@State
	private var connectedPoints: [(Int, Int)] = []
	@State
	private var index: Int = 0
	
	var body: some View {
		ScrollView(showsIndicators: false) {
			gridView
			textInversionView
		}
	}
	
	private var gridView: some View {
		ZStack {
			VStack(spacing: spacing) {
				ForEach(Array(self.matrix.enumerated()), id: \.element) { rowIndex, row in
					HStack(spacing: spacing) {
						ForEach(Array(row.enumerated()), id: \.element) { columnIndex, column in
							RoundedRectangle(cornerRadius: 8)
								.fill(Color.mm_divider_opaque.opacity(0.5))
								.frame(width: cellSize, height: cellSize)
								.scaleEffect(isSelected(Point(row: rowIndex, collomn: columnIndex)) ? 0.8 : 1)
								.overlay(
									RoundedRectangle(cornerRadius: 8)
										.stroke(Color.mm_green, lineWidth: isSelected(Point(row: rowIndex, collomn: columnIndex)) ? 3 : 0) // Зеленая обводка
								)
								.overlay(
									RoundedRectangle(cornerRadius: 8)
										.stroke(Color.mm_warning, lineWidth: isSelectedPoint(Point(row: rowIndex, collomn: columnIndex)) ? 2 : 0)
								)
								.overlay(
									Text("\(column)")
										.font(.title3)
										.foregroundColor(.mm_text_primary)
								)
						}
					}
				}
			}
			createlinePath(points: connectedPoints)
				.stroke(Color.mm_danger, lineWidth: 1)
		}
		.frame(width: frameSize, height: frameSize)
		.padding()
		.task(id: self.matrix.hashValue) {
			self.isRunAnimation = true
			await splash()
			await createPath()
			await createSelectedInverstion()
			self.isRunAnimation = false
		}
	}
	
	private func splash() async {
		if firstPoint == nil || self.secoldPoint == nil { return }
		try? await Task.sleep(nanoseconds: 500 * NSEC_PER_MSEC)
		self.firstPoint = nil
		self.secoldPoint = nil
	}
	
	private var textInversionView: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text("Inversions".localized + ": \(currentCountInversion)" + (self.parity ?? ""))
				.font(.title2)
				.frame(maxWidth: .infinity)
				.multilineTextAlignment(.leading)
			NumberGridView(values: inversions)
				.animation(.spring, value: inversions)
		}
		.frame(maxWidth: .infinity)
	}
	
	private func isSelected(_ point: Point) -> Bool {
		pointOne == point || pointTwo == point
	}
	
	private func isSelectedPoint(_ point: Point) -> Bool {
		if firstPoint == nil { return false }
		return firstPoint == point || secoldPoint == point
	}
	
	private func createPath() async {
		guard self.size > 1 else { return }
		self.connectedPoints.removeAll()
		index = 0
		let stack = generateSnakeStack(n: matrix.count)
		let size = self.size * self.size - 1
		for _ in 0..<size {
			self.connectedPoints.append(stack[self.index])
			self.index += 1
			try? await Task.sleep(nanoseconds: 50 * NSEC_PER_MSEC)
		}
	}
	
	private func createSelectedInverstion() async {
		self.parity = nil
		self.currentCountInversion = 0
		self.inversions.removeAll()
		let inversion = self.checker.getCoupleInversion(matrix: matrix)
		let pointsInversion = inversion.map({ (Point(row: Int($0.0.x), collomn: Int($0.0.y)), Point(row: Int($0.1.x), collomn: Int($0.1.y)))})
		if self.size == 0 { return }
		let nanoseconds = 500 * NSEC_PER_MSEC / UInt64(self.size)
		for points in pointsInversion {
			self.pointOne = points.0
			self.pointTwo = points.1
			self.currentCountInversion += 1
			self.inversions.append("\(matrix[points.0.row][points.0.collomn])-\(matrix[points.1.row][points.1.collomn])")
			try? await Task.sleep(nanoseconds: nanoseconds)
		}
		self.pointOne = nil
		self.pointTwo = nil
		self.parity = " - " + (currentCountInversion.isMultiple(of: 2) ? "Even".localized : "Odd".localized)
	}
	
	private var frameSize: CGFloat {
		if self.size == 0 { return 0 }
		return CGFloat(self.size) * cellSize + CGFloat(self.size - 1) * spacing
	}
	
	private func createlinePath(points: [(Int, Int)]) -> Path {
		// Линии между ячейками
		Path { path in
			for (start, end) in points {
				let startRow = start / size
				let startCol = start % size
				let endRow = end / size
				let endCol = end % size
				
				let startX = CGFloat(startCol) * (cellSize + spacing) + cellSize / 2
				let startY = CGFloat(startRow) * (cellSize + spacing) + cellSize / 2
				let endX = CGFloat(endCol) * (cellSize + spacing) + cellSize / 2
				let endY = CGFloat(endRow) * (cellSize + spacing) + cellSize / 2
				
				path.move(to: CGPoint(x: startX, y: startY))
				path.addLine(to: CGPoint(x: endX, y: endY))
			}
		}
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

struct MatrixView_Previews: PreviewProvider {
	static var previews: some View {
		
//		let matrix: Matrix =
//		[[ 1,  2,  3,  4],
//		 [12, 13, 14,  5],
//		 [11, 10, 15,  6],
//		 [ 0,  9,  8,  7]]
		let matrix: Matrix =
		[[1, 2, 3],
		 [9, 0, 4],
		 [7, 6, 5]]
		let firstPoint = Point(row: 0, collomn: 0)
		let secondPoint = Point(row: 2, collomn: 1)
		return MatrixView(matrix: .constant(matrix), firstPoint: .constant(firstPoint), secoldPoint: .constant(secondPoint), isRunAnimation: .constant(false), checker: MockChecker())
	}
}
