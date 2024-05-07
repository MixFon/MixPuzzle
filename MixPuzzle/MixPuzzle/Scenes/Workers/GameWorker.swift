//
//  GameWorker.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 05.05.2024.
//

import MFPuzzle
import Foundation

protocol _GameWorker {
	func save(matrix: Matrix)
	func load() -> String
}

/// Класс отвечающий за сохранение данных игры.
/// Сохранение состояния игры. Получение цели игры
final class GameWorker: _GameWorker {
	
	private let fileWorker: _FileWorker
	private let fileName = "matrix.mix"
	
	init(fileWorker: _FileWorker) {
		self.fileWorker = fileWorker
	}
	
	func save(matrix: Matrix) {
		var stringRepresentation = "\(matrix.count)\n"
		for row in matrix {
			let rowString = row.map { String($0) }.joined(separator: " ")
			stringRepresentation.append(rowString + "\n")
		}
		self.fileWorker.saveStringToFile(string: stringRepresentation, fileName: self.fileName)
	}
	
	func load() -> String {
		let string = """
4
0 1 2 3
4 5 6 7
8 9 10 11
12 13 14 15
"""
		return self.fileWorker.readStringFromFile(fileName: self.fileName) ?? string
	}
}

final class MockGameWorker: _GameWorker {
	func save(matrix: Matrix) {
		
	}
	
	func load() -> String {
		return ""
	}
}
