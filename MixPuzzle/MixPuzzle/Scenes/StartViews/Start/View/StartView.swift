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
	/// Паблишер для показа решения
	let showSolution = PassthroughSubject<Bool, Never>()
	/// Паблишер для показа меню
	let showMenuSubject = PassthroughSubject<Void, Never>()
	/// Паблишер для обработки окончания игры и создания новой.
	let nextLavelSubject = PassthroughSubject<Void, Never>()
	/// Паблишер для обработки нажатия кнопки начать с начала
	let regenerateSubject = PassthroughSubject<Void, Never>()
	/// Паблишер для показа отображения матрицы
	let showMatrixSubject = PassthroughSubject<Matrix, Never>()
	/// Паблишер вызывающий действия перез закрытием экрана
	let prepareCloseSubject = PassthroughSubject<Void, Never>()
	/// Паблишер для управления поднятия вью с показом пути
	let pathSolutionSubject = PassthroughSubject<StartState, Never>()
	/// Паблишер отправляемый во время старта анимации перемещения узлов при регенерации и отображения пути решения
	/// Блокирует кнопки регенерации, решения и меню в StartScoreView
	let nodesIsRunningSubject = PassthroughSubject<Bool, Never>()
	/// Паблишер для управления запуском и остановки анимации тряски кубиков
	let manageShakeAnimationSubject = PassthroughSubject<ManageShakeMode, Never>()
	/// Паблишер делающий неактивным вью с кнопками по показу пути
	let disablePathButtonsViewSubject = PassthroughSubject<Bool, Never>()
	/// Паблишер удаляющий все анимации у кубиков
	let deleteAllAnimationFromNodeSubject = PassthroughSubject<Void, Never>()

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
	@State private var state: StartState = .game
	@StateObject private var startSceneModel = StartSceneModel()

    var body: some View {
		ZStack {
            StartSceneWrapper(dependency: self.dependency, startSceneModel: startSceneModel)
				.id("scene_static_id")
			VStack {
				StartScoreView(state: self.state, startSceneDependency: startSceneModel)
					.padding(.top, 50)
				Spacer()
				if self.state == .solution {
					VisualizationSolutionPathView(startSceneModel: self.startSceneModel)
						.transition(.move(edge: .bottom))
				}
			}
			.padding(.bottom, 32)
		}
		.onReceive(self.startSceneModel.pathSolutionSubject, perform: { isShowPath in
			withAnimation {
				self.state = isShowPath
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
