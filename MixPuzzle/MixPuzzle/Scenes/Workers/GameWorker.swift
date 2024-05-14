//
//  GameWorker.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 05.05.2024.
//

import MFPuzzle
import Foundation

protocol _GameWorker {
	/// Двумерный массив текущей матрицы
	var matrix: Matrix { get }
	
	/// Сохранение матрицы. Сохраняет текущее сотояние
	func save(matrix: Matrix)
	
	/// Проверка на то, что матрица достигла фильного результата
	func checkSolution(matrix: Matrix) -> Bool
}

/// Класс отвечающий за сохранение данных игры.
/// Сохранение состояния игры. Получение цели игры
final class GameWorker: _GameWorker {
	var matrix: Matrix
	
	private let matrixSolution: Matrix
	
	private let fileWorker: _FileWorker
	private let matrixWorker: _MatrixWorker
	private let settingsGameStorage: _SettingsGameStorage
	
	private let fileNameMatrix = "matrix.mix"
	private let fileNameMatrixSolution = "matrix.solution.mix"
	
	private let defaultMatrix = """
4
 1  2  3  4
12 13 14  5
11  0 15  6
10  9  8  7
"""
	
	init(fileWorker: _FileWorker, matrixWorker: _MatrixWorker, settingsGameStorage: _SettingsGameStorage) {
		self.fileWorker = fileWorker
		self.matrixWorker = matrixWorker
		self.settingsGameStorage = settingsGameStorage
		
		/*
		let textMatrix = self.fileWorker.readStringFromFile(fileName: self.fileNameMatrix) ?? self.defaultMatrix
		self.matrix = (try? matrixWorker.creationMatrix(text: textMatrix)) ?? Matrix()
		
		let textMatrixSolution = self.fileWorker.readStringFromFile(fileName: self.fileNameMatrixSolution) ?? self.defaultMatrix
		self.matrixSolution = (try? matrixWorker.creationMatrix(text: textMatrixSolution)) ?? Matrix()
		 */
		let size = settingsGameStorage.currentLevel
		self.matrix = matrixWorker.createMatrixRandom(size: size)
		self.matrixSolution = matrixWorker.createMatrixSpiral(size: size)
	}
	
	func checkSolution(matrix: Matrix) -> Bool {
		return matrix == self.matrixSolution
	}
	
	func save(matrix: Matrix) {
		var stringRepresentation = "\(matrix.count)\n"
		for row in matrix {
			let rowString = row.map { String($0) }.joined(separator: " ")
			stringRepresentation.append(rowString + "\n")
		}
		self.fileWorker.saveStringToFile(string: stringRepresentation, fileName: self.fileNameMatrix)
	}
}

final class MockGameWorker: _GameWorker {
	var matrix: Matrix = Matrix()
	
	func save(matrix: Matrix) {
		
	}
	
	func checkSolution(matrix: Matrix) -> Bool {
		return true
	}
}
