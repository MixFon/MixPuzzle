//
//  StartView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 22.02.2024.
//

import SwiftUI
import Combine
import MFPuzzle

final class StartSceneModel: ObservableObject {
	/// Паблишер отправляющий массив направлений перемещений нуля
	let pathSubject = PassthroughSubject<[Compass], Never>()
	/// Паблишер для обработки нажатия кнопки сохранить
	let saveSubject = PassthroughSubject<Void, Never>()
	/// Паблишер для показа решения
	let showSolution = PassthroughSubject<Bool, Never>()
	/// Паблишер для обработки нажатия кнопки начать с начала
	let regenerateSubject = PassthroughSubject<Void, Never>()
	
	let compasses: [Compass]
	
	init(compasses: [Compass] = []) {
		self.compasses = compasses
	}
	
	func createRange(currentIndex: Int, selectedIndex: Int) {
		if currentIndex < 0 || selectedIndex < 0 || currentIndex >= self.compasses.count || selectedIndex >= self.compasses.count { return }
		let start = min(currentIndex, selectedIndex)
		let end = max(currentIndex, selectedIndex)
		var range =  Array(self.compasses[start..<end])
		if selectedIndex < currentIndex {
			range = range.reversed().map( { $0.opposite } )
		}
		self.pathSubject.send(range)
	}
}

struct StartView: View {
    let dependency: _Dependency
	@ObservedObject private var startSceneModel = StartSceneModel()
	
    var body: some View {
		ZStack {
            StartSceneWrapper(dependency: self.dependency, startSceneModel: startSceneModel)
				.equatable() // Отключение обновления сцены
			VStack {
				StartScoreView(startSceneDependency: startSceneModel)
					.padding(.top, 50)
				Spacer()
			}
		}
		.preferredColorScheme(.dark)
		.ignoresSafeArea()
    }
}

#Preview {
    let dependency = MockDependency()
    return StartView(dependency: dependency)
}
