//
//  StatisticsWorker.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 13.06.2024.
//

import Foundation

protocol _StatisticsWorker {
	/// Сбрасывает структуру статистики до значений по умолчанию
	func clear()
	/// Увеливение количества побед
	func increaseWins()
	
	/// Загружаем статистику по имени и размеру
	func loadStatistics(name: String, size: Int) -> Statistics?
	
	/// Сохраняет статистику по ключу
	func saveStatistics(name: String, size: Int)
	
	/// Увеличение кодличетсва неудачных ошибок
	func increaseFailedMoves()
	
	/// Увеличение количества генерации новой последовательности
	func increaseRegenerations()
	
	/// Увеличение количества успешних перемещений
	func increaseSuccessfulMoves()
}

struct Statistics: Codable {
	var numberWins: Int = 0
	var numberFailedMoves: Int = 0
	var numberRegenerations: Int = 0
	var numberSuccessfulMoves: Int = 0
}

extension Statistics {
	
	public static func - (lhs: Statistics, rhs: Statistics) -> Statistics {
		let statistics = Statistics(
			numberWins: lhs.numberWins - rhs.numberWins,
			numberFailedMoves: lhs.numberFailedMoves - rhs.numberFailedMoves,
			numberRegenerations: lhs.numberRegenerations - rhs.numberRegenerations,
			numberSuccessfulMoves: lhs.numberSuccessfulMoves - rhs.numberSuccessfulMoves
		)
		return statistics
	}
	
	public static func + (lhs: Statistics, rhs: Statistics) -> Statistics {
		let statistics = Statistics(
			numberWins: lhs.numberWins + rhs.numberWins,
			numberFailedMoves: lhs.numberFailedMoves + rhs.numberFailedMoves,
			numberRegenerations: lhs.numberRegenerations + rhs.numberRegenerations,
			numberSuccessfulMoves: lhs.numberSuccessfulMoves + rhs.numberSuccessfulMoves
		)
		return statistics
	}
}

/// Занимается сохранением статистики
final class StatisticsWorker: _StatisticsWorker {

	private let keeper: _Keeper
	private let decoder: _Decoder
	private var statistics: Statistics
	
	private enum Keys {
		static let statistics = "statistics.mix"
	}
	
	init(keeper: _Keeper, decoder: _Decoder) {
		self.keeper = keeper
		self.decoder = decoder
		self.statistics = Statistics()
	}
	
	func saveStatistics(name: String, size: Int) {
		let saveStatistics: Statistics
		if let loadStatistics = loadStatistics(name: name, size: size) {
			saveStatistics = loadStatistics + self.statistics
		} else {
			saveStatistics = self.statistics
		}
		let fileName = Keys.statistics + ".\(name).\(size)x\(size)"
		if let statisticsString = self.decoder.encode(saveStatistics) {
			self.keeper.saveString(string: statisticsString, fileName: fileName)
		} else {
			print("Ошибка кодирования объекта.")
		}
		clear()
	}
	
	func clear() {
		self.statistics = Statistics()
	}
	
	func increaseWins() {
		self.statistics.numberWins += 1
	}
	
	func increaseFailedMoves() {
		self.statistics.numberFailedMoves += 1
	}
	
	func increaseRegenerations() {
		self.statistics.numberRegenerations += 1
	}
	
	func increaseSuccessfulMoves() {
		self.statistics.numberSuccessfulMoves += 1
	}
	
	func loadStatistics(name: String, size: Int) -> Statistics? {
		let fileName = Keys.statistics + ".\(name).\(size)x\(size)"
		if let statisticsString = self.keeper.readString(fileName: fileName) {
			return self.decoder.decode(Statistics.self, from: statisticsString)
		} else {
			print("Ошибка чтения из файла \(fileName)")
			return nil
		}
	}
}

final class MockStatisticsWorker: _StatisticsWorker {
	func clear() {
		print(#function)
	}
	
	func increaseWins() {
		print(#function)
	}
	
	func saveStatistics(name: String, size: Int) {
		print(#function)
	}
	
	func loadStatistics(name: String, size: Int) -> Statistics? {
		Statistics(
			numberWins: Int.random(in: 0...1000),
			numberFailedMoves: Int.random(in: 0...1000),
			numberRegenerations: Int.random(in: 0...1000),
			numberSuccessfulMoves: Int.random(in: 0...1000)
		)
	}
	
	func increaseFailedMoves() {
		print(#function)
	}
	
	func increaseRegenerations() {
		print(#function)
	}
	
	func increaseSuccessfulMoves() {
		print(#function)
	}
}
