//
//  ManualFillingModel.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 07.11.2026.
//

import SwiftUI
import MFPuzzle

/// Состояние ручного ввода матрицы: клетки, выбранная клетка, размер, цель
/// и проверка решаемости на лету.
@MainActor
final class ManualFillingModel: ObservableObject {

	/// Что сейчас с расстановкой
	enum Status: Equatable {
		/// Заполнены не все клетки
		case incomplete(filled: Int, total: Int)
		/// Число (или пустая клетка — 0) стоит дважды
		case duplicate(value: MatrixElement)
		/// Можно искать решение
		case solvable
		/// Чётность не совпадает с целью: поменять местами эти две клетки
		case unsolvable(swapFirst: Int, swapSecond: Int)
	}

	let sizes = Array(3...5)

	@Published private(set) var size: Int
	@Published var solution: Solution
	/// Клетки построчно. `nil` — ещё не заполнена, `0` — пустая клетка пятнашек.
	@Published private(set) var cells: [MatrixElement?]
	@Published var selectedIndex: Int = 0

	private let checker: _Checker
	private let matrixWorker: _MatrixWorker

	init(checker: _Checker, matrixWorker: _MatrixWorker, size: Int = 3, solution: Solution = .classic) {
		self.checker = checker
		self.matrixWorker = matrixWorker
		self.size = size
		self.solution = solution
		self.cells = Array(repeating: nil, count: size * size)
		self.shuffle()
	}

	// MARK: Состояние

	var status: Status {
		let total = self.cells.count
		var seen = Set<MatrixElement>()
		for case let value? in self.cells {
			if !seen.insert(value).inserted {
				return .duplicate(value: value)
			}
		}
		if seen.count < total {
			return .incomplete(filled: seen.count, total: total)
		}
		let matrix = self.matrix
		if self.checker.checkUniqueElementsMatrix(matrix: matrix),
		   self.checker.checkSolution(matrix: matrix, matrixTarget: self.targetMatrix) {
			return .solvable
		}
		let pair = self.parityFixPair
		return .unsolvable(swapFirst: pair.0, swapSecond: pair.1)
	}

	var isSolvable: Bool {
		self.status == .solvable
	}

	/// Индексы клеток с повторяющимися значениями
	var duplicateIndices: Set<Int> {
		var positions: [MatrixElement: [Int]] = [:]
		for (index, value) in self.cells.enumerated() {
			if let value {
				positions[value, default: []].append(index)
			}
		}
		return Set(positions.values.filter { $0.count > 1 }.flatMap { $0 })
	}

	/// Клетки, которые предлагается поменять местами, если решения нет
	var highlightedIndices: Set<Int> {
		if case let .unsolvable(first, second) = self.status {
			return [first, second]
		}
		return []
	}

	/// Число уже стоит в другой клетке — на клавиатуре его кнопка неактивна
	func isUsed(_ value: MatrixElement) -> Bool {
		self.cells.contains(value) && self.cells[safe: self.selectedIndex] != value
	}

	/// Заполненная матрица (незаполненные клетки считаются нулём)
	var matrix: Matrix {
		(0..<self.size).map { row in
			(0..<self.size).map { column in
				self.cells[row * self.size + column] ?? 0
			}
		}
	}

	var targetMatrix: Matrix {
		self.matrixWorker.createMatrixSolution(size: self.size, solution: self.solution)
	}

	// MARK: Действия

	func select(_ index: Int) {
		guard self.cells.indices.contains(index) else { return }
		self.selectedIndex = index
	}

	/// Ставит число в выбранную клетку и переходит к следующей незаполненной
	func put(_ value: MatrixElement) {
		guard self.cells.indices.contains(self.selectedIndex) else { return }
		self.cells[self.selectedIndex] = value
		if let next = self.nextEmptyIndex(after: self.selectedIndex) {
			self.selectedIndex = next
		}
	}

	func erase() {
		guard self.cells.indices.contains(self.selectedIndex) else { return }
		self.cells[self.selectedIndex] = nil
	}

	/// Новый размер — пустое поле
	func setSize(_ size: Int) {
		guard size != self.size else { return }
		self.size = size
		self.cells = Array(repeating: nil, count: size * size)
		self.selectedIndex = 0
	}

	/// Случайная расстановка, которая гарантированно решается для текущей цели
	func shuffle() {
		var random = self.matrixWorker.createMatrixRandom(size: self.size)
		if !self.checker.checkSolution(matrix: random, matrixTarget: self.targetMatrix) {
			self.matrixWorker.changesParityInvariant(matrix: &random)
		}
		self.cells = random.flatMap { $0 }.map { Optional($0) }
		self.selectedIndex = 0
	}

	/// Меняет местами две непустые клетки: чётность перестановки меняется, и расстановка становится решаемой
	func fixParity() {
		guard case let .unsolvable(first, second) = self.status else { return }
		self.cells.swapAt(first, second)
	}

	// MARK: Вспомогательное

	/// Две клетки с самыми большими числами — их обмен меняет чётность и не трогает пустую клетку
	private var parityFixPair: (Int, Int) {
		let sorted = self.cells.enumerated()
			.compactMap { index, value -> (Int, MatrixElement)? in
				guard let value, value != 0 else { return nil }
				return (index, value)
			}
			.sorted { $0.1 > $1.1 }
		guard sorted.count >= 2 else { return (0, 0) }
		return (sorted[1].0, sorted[0].0)
	}

	private func nextEmptyIndex(after index: Int) -> Int? {
		let count = self.cells.count
		for offset in 1...count {
			let candidate = (index + offset) % count
			if self.cells[candidate] == nil {
				return candidate
			}
		}
		return nil
	}
}

private extension Array {
	subscript(safe index: Int) -> Element? {
		self.indices.contains(index) ? self[index] : nil
	}
}
