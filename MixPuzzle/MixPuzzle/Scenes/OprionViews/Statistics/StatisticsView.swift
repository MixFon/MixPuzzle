//
//  StatisticsView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 15.06.2024.
//

import Charts
import SwiftUI

struct StatisticsDataView: Identifiable {
	let id: UUID = UUID()
	let name: String
	let size: Int
	let data: Statistics
}

@available(iOS 16.0, *)
struct StatisticsView: View {
	let statisticsData: [StatisticsDataView]
	private let cornerRadius: Double = 10
	private let levels = "Levels"
	var body: some View {
		NavigationBar(title: "Target selection")
			.padding()
		ScrollView {
				Chart(self.statisticsData) {
					BarMark(
						x: .value("Date", $0.data.numberFailedMoves),
						y: .value("Coffee", $0.name)
					)
					.cornerRadius(self.cornerRadius)
					.foregroundStyle(by: .value("Shape Color", $0.size))
				}
				.aspectRatio(contentMode: .fit)
				.chartXAxisLabel(self.levels)
				.chartYAxisLabel("numberFailedMoves")
				.padding()
				Chart(self.statisticsData) {
					BarMark(
						x: .value("Date", $0.data.numberRegenerations),
						y: .value("Coffee", $0.name)
					)
					.cornerRadius(self.cornerRadius)
					.foregroundStyle(by: .value("Shape Color", $0.size))
				}
				.aspectRatio(contentMode: .fit)
				.chartXAxisLabel(self.levels)
				.chartYAxisLabel("numberRegenerations")
				.padding()
				Chart(self.statisticsData) {
					BarMark(
						x: .value("Date", $0.data.numberSuccessfulMoves),
						y: .value("Coffee", $0.name)
					)
					.cornerRadius(self.cornerRadius)
					.foregroundStyle(by: .value("Shape Color", $0.size))
				}
				.aspectRatio(contentMode: .fit)
				.chartXAxisLabel(self.levels)
				.chartYAxisLabel("numberSuccessfulMoves")
				.padding()
				Chart(self.statisticsData) {
					BarMark(
						x: .value("Date", $0.data.numberWins),
						y: .value("Coffee", $0.name)
					)
					.cornerRadius(self.cornerRadius)
					.foregroundStyle(by: .value("Shape Color", $0.size))
				}
				.aspectRatio(contentMode: .fit)
				.chartXAxisLabel(self.levels)
				.chartYAxisLabel("numberWins")
				.padding()
		}
	}
	
	func getStatisticsFor(size: Int) -> [StatisticsDataView] {
		return self.statisticsData.filter( {$0.size == size} )
	}
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview {
	let statisticsData: [StatisticsDataView] = [
		StatisticsDataView(name: "Classic", size: 3, data: Statistics(numberWins: 10, numberFailedMoves: 4, numberRegenerations: 3, numberSuccessfulMoves: Int.random(in: 0...1000))),
		StatisticsDataView(name: "Snail", size: 3, data: Statistics(numberWins: 11, numberFailedMoves: 6, numberRegenerations: 5, numberSuccessfulMoves: Int.random(in: 0...1000))),
		StatisticsDataView(name: "Boustrophedon", size: 3, data: Statistics(numberWins: 12, numberFailedMoves: 8, numberRegenerations: 7, numberSuccessfulMoves: Int.random(in: 0...1000))),
		StatisticsDataView(name: "Classic", size: 4, data: Statistics(numberWins: 13, numberFailedMoves: 10, numberRegenerations: 9, numberSuccessfulMoves: Int.random(in: 0...1000))),
		StatisticsDataView(name: "Snail", size: 4, data: Statistics(numberWins: 14, numberFailedMoves: 12, numberRegenerations: 11, numberSuccessfulMoves: Int.random(in: 0...1000))),
		StatisticsDataView(name: "Boustrophedon", size: 4, data: Statistics(numberWins: 15, numberFailedMoves: 14, numberRegenerations: 13, numberSuccessfulMoves: Int.random(in: 0...1000))),
		StatisticsDataView(name: "Classic", size: 5, data: Statistics(numberWins: 16, numberFailedMoves: 16, numberRegenerations: 15, numberSuccessfulMoves: Int.random(in: 0...1000))),
		StatisticsDataView(name: "Snail", size: 5, data: Statistics(numberWins: 17, numberFailedMoves: 18, numberRegenerations: 17, numberSuccessfulMoves: Int.random(in: 0...1000))),
		StatisticsDataView(name: "Boustrophedon", size: 5, data: Statistics(numberWins: 18, numberFailedMoves: 20, numberRegenerations: 19, numberSuccessfulMoves: Int.random(in: 0...1000))),
	]
	return StatisticsView(statisticsData: statisticsData)
}
