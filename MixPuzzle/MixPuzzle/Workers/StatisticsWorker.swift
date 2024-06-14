//
//  StatisticsWorker.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 13.06.2024.
//

import Foundation

protocol _StatisticsWorker {
	/// Сохраняет статистику по ключу
	func saveStatistic(name: String, size: Int, statistic: Statistics)
	
	/// Загрузить статистику по ключу
	func loadStatistic(name: String, size: Int) -> Statistics?
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
	
	private enum Keys {
		static let statistics = "statistics.mix"
	}
	
	init(keeper: _Keeper, decoder: _Decoder) {
		self.keeper = keeper
		self.decoder = decoder
	}
	
	func saveStatistic(name: String, size: Int, statistic: Statistics) {
		let fileName = Keys.statistics + ".\(name).\(size)x\(size)"
		if let statisticsString = self.decoder.encode(statistic) {
			self.keeper.saveString(string: statisticsString, fileName: fileName)
		} else {
			print("Ошибка кодирования объекта.")
		}
	}
	
	func loadStatistic(name: String, size: Int) -> Statistics? {
		let fileName = Keys.statistics + ".\(name).\(size)x\(size)"
		if let statisticsString = self.keeper.readString(fileName: fileName) {
			return self.decoder.decode(Statistics.self, from: statisticsString)
		} else {
			print("Ошибка чтения из файла \(fileName)")
			return nil
		}
	}
}
