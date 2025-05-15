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

struct MatrixView: View {
	let cellSize: CGFloat = 50
	let spacing: CGFloat = 10
	let matrix: Matrix
	
	var size: Int {
		self.matrix.count
	}
	
	// Пары точек для соединения (индексы ячеек: строка * size + столбец)
	@State
	var connectedPoints: [(Int, Int)] = [] // Пример: соединяем 0->1->2 (диагональ)
	
	@State
	private var index: Int = 0
	
	var body: some View {
		VStack {
			ZStack {
				VStack(spacing: spacing) {
					ForEach(self.matrix, id: \.self) { row in
						HStack(spacing: spacing) {
							ForEach(row, id: \.self) { column in
								RoundedRectangle(cornerRadius: 8)
									.fill(Color.gray.opacity(0.2))
									.frame(width: cellSize, height: cellSize)
									.overlay(
										Text("\(column)")
											.foregroundColor(.black)
									)
							}
						}
					}
				}
				// Линии между ячейками
				Path { path in
					for (start, end) in connectedPoints {
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
				.stroke(Color.red, lineWidth: 5)
			}
			.frame(width: frameSize, height: frameSize)
			.padding()
			.border(Color.red)
			Button("Press") {
				if self.index < self.size * self.size - 1{
					let stack = generateSnakeStack(n: self.size)
					self.connectedPoints.append(stack[self.index])
					self.index += 1
				}
			}
		}
	}
	
	private var frameSize: CGFloat {
		CGFloat(self.size) * cellSize + CGFloat(self.size - 1) * spacing
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
		let matrix: Matrix =
		[[ 1,  2,  3,  4],
		 [12, 13, 14,  5],
		 [11, 10, 15,  6],
		 [ 0,  9,  8,  7]]
//		let matrix: Matrix =
//		[[1, 2, 3],
//		 [9, 0, 4],
//		 [7, 6, 5]]
		return MatrixView(matrix: matrix)
	}
}
