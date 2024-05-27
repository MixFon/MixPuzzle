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
	
	/// Тип решения головоломки
	var solution: Solution { get }
	
	/// Сохранение матрицы. Сохраняет текущее сотояние
	func save(matrix: Matrix)
	
	/// Сохранение цели решения головоломки
	func save(solution: Solution)
	
	/// Проверка на то, что матрица достигла фильного результата
	func checkSolution(matrix: Matrix) -> Bool
	
	var solutionOptions: [MatrixSolution] { get }
	
	/// Функция обновления матриц
	func updateMatrix()
	
	/// Создание новой матрицы
	func regenerateMatrix()
}

struct MatrixSolution {
	let type: Solution
	let matrix: Matrix
}

/// Класс отвечающий за сохранение данных игры.
/// Сохранение состояния игры. Получение цели игры
final class GameWorker: _GameWorker {
	var matrix: Matrix
	
	var solutionOptions: [MatrixSolution] {
		let size = self.settingsGameStorage.currentLevel
		return Solution.allCases.map { MatrixSolution(type: $0, matrix: self.matrixWorker.createMatrixSolution(size: size, solution: $0)) }
	}
	
	private var matrixSolution: Matrix
	
	private let checker: _Checker
	private let fileWorker: _FileWorker
	private let matrixWorker: _MatrixWorker
	private let settingsGameStorage: _SettingsGameStorage
	private let defaults = UserDefaults.standard
	
	private enum Keys {
		static let solution = "solution.mix"
		static let fileNameMatrix = "matrix.mix"
	}
	
	var solution: Solution {
		get {
			if let nameSolution = self.defaults.string(forKey: Keys.solution) {
				return Solution(rawValue: nameSolution) ?? .classic
			} else {
				return .classic
			}
		}
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
	
	func save(solution: Solution) {
		self.defaults.set(solution.rawValue, forKey: Keys.solution)
	}
	
	func updateMatrix() {
		self.matrix = loadOrCreateMatrix()
		let size = self.settingsGameStorage.currentLevel
		self.matrixSolution = self.matrixWorker.createMatrixSolution(size: size, solution: self.solution)
		// В случае, если из матрицы нельзя получить ответ, генерируем матрицу заново
		if !self.checker.checkSolution(matrix: self.matrix, matrixTarget: self.matrixSolution) {
			regenerateMatrix()
		}
	}
	
	func regenerateMatrix() {
		let size = self.settingsGameStorage.currentLevel
		self.matrix = self.matrixWorker.createMatrixRandom(size: size)
		if !checker.checkSolution(matrix: self.matrix, matrixTarget: self.matrixSolution) {
			self.matrixWorker.changesParityInvariant(matrix: &self.matrix)
			print(checker.checkSolution(matrix: self.matrix, matrixTarget: self.matrixSolution))
		}
	}
	
	private var lavelFileNameMatrix: String {
		let size = self.settingsGameStorage.currentLevel
		return Keys.fileNameMatrix + ".\(size)x\(size)"
	}
	
	/// Загружает сохраненную матрицу или создает новую
	private func loadOrCreateMatrix() -> Matrix {
		let size = self.settingsGameStorage.currentLevel
		guard let textMatrix = self.fileWorker.readStringFromFile(fileName: self.lavelFileNameMatrix) else {
			return self.matrixWorker.createMatrixRandom(size: size)
		}
		return (try? matrixWorker.creationMatrix(text: textMatrix)) ?? self.matrixWorker.createMatrixRandom(size: size)
	}
}

final class MockGameWorker: _GameWorker {
	
	var solution: Solution = .classic
	
	var matrix: Matrix {
		[[1, 2, 3],
		 [4, 5, 6],
		 [7, 8, 0]]
	}
	
	var solutionOptions: [MatrixSolution] {
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
		let snail: Matrix = [
			[1, 2, 3],
			[8, 0, 4],
			[7, 6, 5],
		]
		let solutions: [MatrixSolution] = [
			MatrixSolution(type: .classic, matrix: classic),
			MatrixSolution(type: .snail, matrix: snail),
			MatrixSolution(type: .boustrophedon, matrix: snake),
		]
		return solutions
	}
	
	func save(matrix: Matrix) {
		print(#function)
	}
	
	func save(solution: Solution) {
		print(#function)
	}
	
	func checkSolution(matrix: Matrix) -> Bool {
		return true
	}
	
	func updateMatrix() {
		print(#function)
	}
	
	func regenerateMatrix() {
		print(#function)
	}
	
}
