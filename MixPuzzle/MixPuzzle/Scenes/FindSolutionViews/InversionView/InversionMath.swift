//
//  InversionMath.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 07.11.2026.
//

import MFPuzzle

/// Пара-инверсия: большее число стоит раньше меньшего
struct InversionPair: Hashable {
	let greater: MatrixElement
	let smaller: MatrixElement
}

/// Подсчёт инверсий для экранов объяснения. Считает так же, как `Checker`:
/// клетки выписываются «змейкой», пустая клетка (0) не участвует.
enum InversionMath {

	/// Индексы клеток в порядке обхода: по строкам или «змейкой» (нечётные строки справа налево)
	static func order(size: Int, snake: Bool) -> [Int] {
		(0..<size).flatMap { row -> [Int] in
			let columns = Array(0..<size)
			let ordered = (snake && row % 2 == 1) ? columns.reversed() : columns
			return ordered.map { row * size + $0 }
		}
	}

	/// Числа поля в порядке обхода, без пустой клетки
	static func sequence(_ cells: [MatrixElement], size: Int, snake: Bool) -> [MatrixElement] {
		self.order(size: size, snake: snake)
			.compactMap { cells.indices.contains($0) ? cells[$0] : nil }
			.filter { $0 != 0 }
	}

	static func pairs(in sequence: [MatrixElement]) -> [InversionPair] {
		var result: [InversionPair] = []
		for (i, first) in sequence.enumerated() {
			for second in sequence[(i + 1)...] where first > second {
				result.append(InversionPair(greater: first, smaller: second))
			}
		}
		return result
	}

	/// Число инверсий при обходе змейкой — его чётность и определяет решаемость
	static func count(_ cells: [MatrixElement], size: Int) -> Int {
		self.pairs(in: self.sequence(cells, size: size, snake: true)).count
	}

	/// Индексы соседних с пустой клеткой плиток
	static func neighborsOfBlank(_ cells: [MatrixElement], size: Int) -> [Int] {
		guard let blank = cells.firstIndex(of: 0) else { return [] }
		let row = blank / size
		let column = blank % size
		var result: [Int] = []
		if row > 0 { result.append(blank - size) }
		if row < size - 1 { result.append(blank + size) }
		if column > 0 { result.append(blank - 1) }
		if column < size - 1 { result.append(blank + 1) }
		return result
	}

	/// Собранное поле: 1…n²−1 и пустая клетка в конце
	static func solved(size: Int) -> [MatrixElement] {
		(1..<(size * size)).map { MatrixElement($0) } + [0]
	}
}
