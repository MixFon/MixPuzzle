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
	/// Двумерный массив матрицы решения
	var matrixSolution: Matrix { get }
	/// Двумерный массив из которого начинается игра
	var matrixInitiate: Matrix { get }
	/// Воркер для управления статистикой
	var statisticsWorker: _StatisticsWorker { get }
	
	/// Тип решения головоломки
	var solution: Solution { get }
	
	/// Возможные решения коловоломки
	var solutionOptions: [MatrixSolution] { get }
	
	/// Сохранение матрицы. Сохраняет текущее сотояние
	func save(matrix: Matrix)
	
	/// Сохранение цели решения головоломки
	func save(solution: Solution)
	
	/// Сохранение статистики для текущего состояния
	func saveStatistics()

	/// Проверка на то, что матрица достигла фильного результата
	func checkSolution(matrix: Matrix) -> Bool
	
	/// Функция обновления матриц, загружает или создает новую
	func updateMatrix()
	
	/// Обновляет текущую матрицу
	func updateMatrix(matrix: Matrix)
	
	/// Создание новой матрицы
	func regenerateMatrix()
	
	/// Устанавливает направление передвижения нуля. Куда передвинуля ноль
	func setCompass(compass: Compass)
	
	/// Загружает компасы из хранилища
	func loadCompasses() -> [Compass]
	
	/// Сохраняет компаты в хранилище
	func saveCompasses()
	
	/// Стирает все компасы из хранилища
	func deleteCompasses()
	
	/// Повышение текущего уровня игры
	func increaseLavel()
	
	/// Возвращает статистику по всем уровням
	func getStatistics() -> [StatisticsDataView]
}

struct MatrixSolution {
	let type: Solution
	let matrix: Matrix
}

/// Класс отвечающий за сохранение данных игры.
/// Сохранение состояния игры. Получение цели игры
final class GameWorker: _GameWorker {
	var matrix: Matrix
	var matrixInitiate: Matrix
	var matrixSolution: Matrix
	var statisticsWorker: _StatisticsWorker

	var solutionOptions: [MatrixSolution] {
		let size = self.settingsGameStorage.currentLevel
		return Solution.allCases.map { MatrixSolution(type: $0, matrix: self.matrixWorker.createMatrixSolution(size: size, solution: $0)) }
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
	
	private var compasses: [Compass]
	
	private let keeper: _Keeper
	private let checker: _Checker
	private let matrixWorker: _MatrixWorker
	private var settingsGameStorage: _SettingsGameStorage
	private let defaults = UserDefaults.standard
	
	private enum Keys {
		static let solution = "solution.mix"
		static let compasses = "compasses.mix"
		static let statistics = "statistics.mix"
		static let fileNameMatrix = "matrix.mix"
	}
	
	init(checker: _Checker, keeper: _Keeper, matrixWorker: _MatrixWorker, statisticsWorker: _StatisticsWorker, settingsGameStorage: _SettingsGameStorage) {
		self.checker = checker
		self.keeper = keeper
		self.matrixWorker = matrixWorker
		self.statisticsWorker = statisticsWorker
		self.settingsGameStorage = settingsGameStorage
		
		self.matrix = Matrix()
		self.compasses = []
		self.matrixInitiate = Matrix()
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
		self.keeper.saveString(string: stringRepresentation, fileName: self.lavelFileNameMatrix)
	}
	
	func save(solution: Solution) {
		self.defaults.set(solution.rawValue, forKey: Keys.solution)
	}
	
	func saveStatistics() {
		let name = self.solution.rawValue
		let size = self.settingsGameStorage.currentLevel
		self.statisticsWorker.saveStatistics(name: name, size: size)
	}
	
	func updateMatrix() {
		self.matrix = loadOrCreateMatrix()
//		self.matrix = [
//			[1, 2, 3],
//			[4, 5, 6],
//			[7, 0, 8]
//		]
		let size = self.settingsGameStorage.currentLevel
//		let size = 3
		self.matrixSolution = self.matrixWorker.createMatrixSolution(size: size, solution: self.solution)
		// В случае, если из матрицы нельзя получить ответ, генерируем матрицу заново
		if !self.checker.checkSolution(matrix: self.matrix, matrixTarget: self.matrixSolution) {
			regenerateMatrix()
		}
	}
	
	func updateMatrix(matrix: Matrix) {
		self.matrix = matrix
	}
	
	func regenerateMatrix() {
		let size = self.settingsGameStorage.currentLevel
		self.matrix = self.matrixWorker.createMatrixRandom(size: size)
		self.matrixSolution = self.matrixWorker.createMatrixSolution(size: size, solution: self.solution)
		defer { self.matrixInitiate = self.matrix }
		if !checker.checkSolution(matrix: self.matrix, matrixTarget: self.matrixSolution) {
			self.matrixWorker.changesParityInvariant(matrix: &self.matrix)
			debugPrint(checker.checkSolution(matrix: self.matrix, matrixTarget: self.matrixSolution))
		}
	}
	
	func setCompass(compass: Compass) {
		self.compasses.append(compass)
	}
	
	func saveCompasses() {
		var savedCompasses = loadCompasses()
		savedCompasses.append(contentsOf: self.compasses)
		let compassesString = savedCompasses.compactMap( { $0.toString } ).joined(separator: ",")
		self.compasses.removeAll()
		self.keeper.saveString(string: compassesString, fileName: self.lavelFileNameCompasses)
	}
	
	func loadCompasses() -> [Compass] {
		if let compassesString = self.keeper.readString(fileName: self.lavelFileNameCompasses) {
			return compassesString.split(separator: ",").compactMap( { Compass(string: String($0)) } )
		} else {
			return []
		}
	}
	
	func deleteCompasses() {
		self.compasses.removeAll()
		self.keeper.saveString(string: "", fileName: self.lavelFileNameCompasses)
	}
	
	func increaseLavel() {
		guard settingsGameStorage.currentLevel < settingsGameStorage.availableLevel else { return }
		self.settingsGameStorage.currentLevel += 1
		if self.settingsGameStorage.currentLevel > self.settingsGameStorage.maxAchievedLevel {
			self.settingsGameStorage.maxAchievedLevel += 1
		}
	}
	
	func getStatistics() -> [StatisticsDataView] {
		var statisticsData: [StatisticsDataView] = []
		for solution in Solution.allCases {
			let name = solution.rawValue
			for size in 3...self.settingsGameStorage.maxAchievedLevel {
				guard let loadedStatistics = self.statisticsWorker.loadStatistics(name: name, size: size) else { continue }
				let data = StatisticsDataView(
					name: solution.name,
					size: size,
					data: loadedStatistics
				)
				statisticsData.append(data)
			}
		}
		return statisticsData
	}
	
	private var lavelFileNameMatrix: String {
		let size = self.settingsGameStorage.currentLevel
		return Keys.fileNameMatrix + ".\(size)x\(size)"
	}
	
	private var lavelFileNameCompasses: String {
		let size = self.settingsGameStorage.currentLevel
		return Keys.compasses + ".\(size)x\(size)"
	}
	
	/// Загружает сохраненную матрицу или создает новую
	private func loadOrCreateMatrix() -> Matrix {
		let size = self.settingsGameStorage.currentLevel
		guard let textMatrix = self.keeper.readString(fileName: self.lavelFileNameMatrix) else {
			return self.matrixWorker.createMatrixRandom(size: size)
		}
		return (try? matrixWorker.creationMatrix(text: textMatrix)) ?? self.matrixWorker.createMatrixRandom(size: size)
	}
}

extension Compass {
	
	init?(string: String) {
		switch string {
		case "north":
			self = .north
		case "west":
			self = .west
		case "east":
			self = .east
		case "south":
			self = .south
		case "needle":
			self = .needle
		default:
			return nil
		}
	}
	
	var toString: String {
		switch self {
		case .west:
			"west"
		case .east:
			"east"
		case .north:
			"north"
		case .south:
			"south"
		case .needle:
			"needle"
		}
	}
}

final class MockGameWorker: _GameWorker {
	
	var statisticsWorker:  _StatisticsWorker = MockStatisticsWorker()

	var solution: Solution = .classic
	
	var matrix: Matrix {
		[[1, 2, 3],
		 [4, 5, 6],
		 [7, 8, 0]]
	}
	
	var matrixInitiate: Matrix {
		[[1, 2, 3],
		 [4, 5, 6],
		 [7, 8, 0]]
	}
	
	var matrixSolution: Matrix {
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
		debugPrint(#function)
	}
	
	func save(solution: Solution) {
		debugPrint(#function)
	}
	
	func saveStatistics() {
		debugPrint(#function)
	}

	func checkSolution(matrix: Matrix) -> Bool {
		return true
	}
	
	func updateMatrix() {
		debugPrint(#function)
	}
	
	func updateMatrix(matrix: Matrix) {
		debugPrint(#function)
	}
	
	func regenerateMatrix() {
		debugPrint(#function)
	}
	
	func setCompass(compass: Compass) {
		debugPrint(#function)
	}
	
	func getStatistics() -> [StatisticsDataView] {
		[]
	}
	
	func saveCompasses() {
		debugPrint(#function)
	}
	
	func loadCompasses() -> [Compass] {
		return []
	}
	
	func deleteCompasses() {
		debugPrint(#function)
	}
	
	func increaseLavel() {
		debugPrint(#function)
	}
	
}
