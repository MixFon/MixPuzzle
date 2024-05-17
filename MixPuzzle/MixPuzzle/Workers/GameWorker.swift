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
	
	/// Функция обновления матриц
	func updateMatrix()
	
	/// Создание новой матрицы
	func regenerateMatrix()
}

/// Класс отвечающий за сохранение данных игры.
/// Сохранение состояния игры. Получение цели игры
final class GameWorker: _GameWorker {
	var matrix: Matrix
	
	private var matrixSolution: Matrix
	
	private let checker: _Checker
	private let fileWorker: _FileWorker
	private let matrixWorker: _MatrixWorker
	private let settingsGameStorage: _SettingsGameStorage
	
	private let fileNameMatrix = "matrix.mix"
	private let fileNameMatrixSolution = "matrix.solution.mix"
	
	private var lavelFileNameMatrix: String {
		let size = self.settingsGameStorage.currentLevel
		return self.fileNameMatrix + ".\(size)x\(size)"
	}
	
	private var lavelFileNameMatrixSolution: String {
		let size = self.settingsGameStorage.currentLevel
		return self.fileNameMatrixSolution + ".\(size)x\(size)"
	}
	
	init(checker: _Checker, fileWorker: _FileWorker, matrixWorker: _MatrixWorker, settingsGameStorage: _SettingsGameStorage) {
		self.checker = checker
		self.fileWorker = fileWorker
		self.matrixWorker = matrixWorker
		self.settingsGameStorage = settingsGameStorage
		
		self.matrix = Matrix()
		self.matrixSolution = Matrix()
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
		self.fileWorker.saveStringToFile(string: stringRepresentation, fileName: self.lavelFileNameMatrix)
	}
	
	func updateMatrix() {
		self.matrix = loadOrCreateMatrix()
		self.matrixSolution = loadOrCreateMatrixSolution()
	}
	
	func regenerateMatrix() {
		let size = self.settingsGameStorage.currentLevel
		self.matrix = self.matrixWorker.createMatrixRandom(size: size)
		if !checker.checkSolution(matrix: self.matrix, matrixTarget: self.matrixSolution) {
			self.matrixWorker.changesParityInvariant(matrix: &self.matrix)
			print(checker.checkSolution(matrix: self.matrix, matrixTarget: self.matrixSolution))
		}
	}
	
	/// Загружает сохраненную матрицу или создает новую
	private func loadOrCreateMatrix() -> Matrix {
		let size = self.settingsGameStorage.currentLevel
		guard let textMatrix = self.fileWorker.readStringFromFile(fileName: self.lavelFileNameMatrix) else {
			return self.matrixWorker.createMatrixRandom(size: size)
		}
		return (try? matrixWorker.creationMatrix(text: textMatrix)) ?? self.matrixWorker.createMatrixRandom(size: size)
	}
	
	/// Загружает сохраненную матрицу ответа или создает новую
	private func loadOrCreateMatrixSolution() -> Matrix {
		let size = self.settingsGameStorage.currentLevel
		guard let textMatrixSolution = self.fileWorker.readStringFromFile(fileName: self.lavelFileNameMatrixSolution) else {
			return self.matrixWorker.createMatrixSpiral(size: size)
		}
		return (try? matrixWorker.creationMatrix(text: textMatrixSolution)) ?? self.matrixWorker.createMatrixSpiral(size: size)
	}
}

final class MockGameWorker: _GameWorker {
	
	var matrix: Matrix = Matrix()
	
	func save(matrix: Matrix) {
		
	}
	
	func checkSolution(matrix: Matrix) -> Bool {
		return true
	}
	
	func updateMatrix() {
		
	}
	
	func regenerateMatrix() {
		
	}
	
}
