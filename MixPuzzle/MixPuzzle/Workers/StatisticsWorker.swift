//
//  StatisticsWorker.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 13.06.2024.
//

import Foundation

protocol _StatisticsWorker {
	/// Сохраняет статистику по ключу
	func saveStatistic(key: String, statistic: Statistics)
	
	/// Загрузить статистику по ключу
	func loadStatistic(key: String) -> Statistics?
}

struct Statistics: Codable {
	var name: String
	var size: Int
	var numberWins: Int
	var numberFailedMoves: Int
	var numberSuccessfulMoves: Int
}

final class StatisticsWorker: _StatisticsWorker {
	
	private let keeper: _Keeper
	
	init(keeper: _Keeper) {
		self.keeper = keeper
	}
	
	func saveStatistic(key: String, statistic: Statistics) {
		
	}
	
	func loadStatistic(key: String) -> Statistics? {
		return nil
	}
}
