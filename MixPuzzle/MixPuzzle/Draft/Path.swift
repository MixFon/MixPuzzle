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
	let stack: [(Int, Int)]
	let matrix: Matrix
	let pointsInversion: [(Point, Point)]
	private let cellSize: CGFloat = 50
	private let spacing: CGFloat = 10
	private var size: Int {
		self.matrix.count
	}
	
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
	private var connectedPoints: [(Int, Int)] = [] // Пример: соединяем 0->1->2 (диагональ)
	@State
	private var index: Int = 0
	
	
	var body: some View {
		ScrollView {
			VStack {
				gridView
				textInversionView
			}
		}
	}
	
	private var gridView: some View {
		ZStack {
			VStack(spacing: spacing) {
				ForEach(Array(self.matrix.enumerated()), id: \.element) { rowIndex, row in
					HStack(spacing: spacing) {
						ForEach(Array(row.enumerated()), id: \.element) { columnIndex, column in
							RoundedRectangle(cornerRadius: 8)
								.fill(Color.gray.opacity(0.2))
								.frame(width: cellSize, height: cellSize)
								.scaleEffect(isSelected(Point(row: rowIndex, collomn: columnIndex)) ? 0.8 : 1)
								.overlay(
									RoundedRectangle(cornerRadius: 8)
										.stroke(Color.mm_green, lineWidth: isSelected(Point(row: rowIndex, collomn: columnIndex)) ? 3 : 0) // Зеленая обводка
								)
								.overlay(
									Text("\(column)")
										.foregroundColor(.black)
								)
						}
					}
				}
			}
			createlinePath(points: connectedPoints)
				.stroke(Color.red, lineWidth: 1)
		}
		.frame(width: frameSize, height: frameSize)
		.padding()
		.task {
			await createPath()
			await createSelectedInverstion()
		}
	}
	
	private var textInversionView: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Инверсии: \(currentCountInversion)")
				.font(.title2)
				.frame(maxWidth: .infinity)
				.multilineTextAlignment(.leading)
			NumberGridView(values: inversions)
				.animation(.spring, value: inversions)
		}
		.frame(maxWidth: .infinity)
		.padding()
	}
	
	private func isSelected(_ point: Point) -> Bool {
		pointOne == point || pointTwo == point
	}
	
	private func createPath() async {
		let size = self.size * self.size - 1
		for _ in 0..<size {
			self.connectedPoints.append(self.stack[self.index])
			self.index += 1
			try? await Task.sleep(nanoseconds: 50 * NSEC_PER_MSEC)
		}
	}
	
	private func createSelectedInverstion() async {
		self.currentCountInversion = 0
		for points in pointsInversion {
			self.pointOne = points.0
			self.pointTwo = points.1
			self.currentCountInversion += 1
			self.inversions.append("\(matrix[points.0.row][points.0.collomn])-\(matrix[points.1.row][points.1.collomn])")
			try? await Task.sleep(nanoseconds: 500 * NSEC_PER_MSEC)
		}
		self.pointOne = nil
		self.pointTwo = nil
	}
	
	private var frameSize: CGFloat {
		CGFloat(self.size) * cellSize + CGFloat(self.size - 1) * spacing
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
}

struct MatrixView_Previews: PreviewProvider {
	static var previews: some View {
		
		func generateSnakeStack(n: Int) -> [(Int, Int)] {
			let matrix = (0..<n).map { i in
				let row = (0..<n).map { j in i * n + j }
				return i % 2 == 0 ? row : row.reversed()
			}

			let arr = matrix.flatMap { $0 }

			return (1..<arr.count).map { i in (arr[i - 1], arr[i]) }
		}
		
//		let matrix: Matrix =
//		[[ 1,  2,  3,  4],
//		 [12, 13, 14,  5],
//		 [11, 10, 15,  6],
//		 [ 0,  9,  8,  7]]
				let matrix: Matrix =
				[[1, 2, 3],
				 [9, 0, 4],
				 [7, 6, 5]]
		let checker = Checker()
		let inversion = checker.getCoupleInversion(matrix: matrix)
		let pointsInversion: [(Point, Point)] = inversion.map({ (Point(row: Int($0.0.x), collomn: Int($0.0.y)), Point(row: Int($0.1.x), collomn: Int($0.1.y)))})
			
		return MatrixView(stack: generateSnakeStack(n: matrix.count), matrix: matrix, pointsInversion: pointsInversion)
	}
}
