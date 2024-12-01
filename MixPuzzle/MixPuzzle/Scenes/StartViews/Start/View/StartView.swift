//
//  StartView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 22.02.2024.
//

import SwiftUI
import Combine
import MFPuzzle

enum StartState {
	/// Состояние игры. Ввержу 3 кнопки
	case game
	/// Состояние меню. Вверху только назад и показано меню.
	case menu
	/// Показ решения. Вниду компас. Вверху назад и флаг
	case solution
}

final class StartSceneRouter: ObservableObject {
	@Published var state: StartState = .game
	@Published var onClose: Bool = false
}

final class StartSceneModel: ObservableObject {
	/// Паблишер отправляющий массив направлений перемещений нуля
	let pathSubject = PassthroughSubject<[Compass], Never>()
	/// Паблишер для обработки нажатия кнопки сохранить
	let saveSubject = PassthroughSubject<Void, Never>()
	/// Паблишер для показа решения
	let showSolution = PassthroughSubject<Bool, Never>()
	/// Паблишер для показа меню
	let showMenuSubject = PassthroughSubject<Void, Never>()
	/// Паблишер для обработки окончания игры и создания новой.
	let nextLavelSubject = PassthroughSubject<Void, Never>()
	/// Паблишер для обработки нажатия кнопки начать с начала
	let regenerateSubject = PassthroughSubject<Void, Never>()
	/// Паблишер для управления поднятия вью с показом пути
	let pathSolutionSubject = PassthroughSubject<StartState, Never>()

	var compasses: [Compass] = []
	
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
	@ObservedObject private var router = StartSceneRouter()
	@ObservedObject private var startSceneModel = StartSceneModel()

    var body: some View {
		ZStack {
            StartSceneWrapper(dependency: self.dependency, startSceneModel: startSceneModel)
				.equatable() // Отключение обновления сцены
			VStack {
				StartScoreView(state: self.router.state, startSceneDependency: startSceneModel)
					.padding(.top, 50)
				Spacer()
				if self.router.state == .solution {
					VisualizationSolutionPathView(startSceneModel: self.startSceneModel)
						.background(Color.mm_background_tertiary)
						.transition(.move(edge: .bottom))
						.padding(.bottom)
				}
			}
		}
		.onReceive(self.startSceneModel.pathSolutionSubject, perform: { isShowPath in
			withAnimation {
				self.router.state = isShowPath
			}
		})
		.preferredColorScheme(.dark)
		.ignoresSafeArea()
    }
}

#Preview {
    let dependency = MockDependency()
    return StartView(dependency: dependency)
}
