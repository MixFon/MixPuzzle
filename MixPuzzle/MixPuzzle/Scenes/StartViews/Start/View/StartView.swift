//
//  StartView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 22.02.2024.
//

import SwiftUI
import Combine
import MFPuzzle

final class StartSceneRouter: ObservableObject {
	@Published var toSolution = false
}

final class StartSceneModel: ObservableObject {
	/// Паблишер отправляющий массив направлений перемещений нуля
	let pathSubject = PassthroughSubject<[Compass], Never>()
	/// Паблишер для обработки нажатия кнопки сохранить
	let saveSubject = PassthroughSubject<Void, Never>()
	/// Паблишер для показа решения
	let showSolution = PassthroughSubject<Bool, Never>()
	/// Паблишер для обработки окончания инры и создания новой.
	let finishSubject = PassthroughSubject<Void, Never>()
	/// Паблишер для обработки нажатия кнопки начать с начала
	let regenerateSubject = PassthroughSubject<Void, Never>()
	/// Паблишер для управления поднятия вью с показом пути
	let pathSolutionSubject = PassthroughSubject<Bool, Never>()
	
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
	@State private var onClose: Bool = false
	@State private var showVisualizationView = false
	
    var body: some View {
		ZStack {
            StartSceneWrapper(dependency: self.dependency, startSceneModel: startSceneModel)
				.equatable() // Отключение обновления сцены
			VStack {
				StartScoreView(startSceneDependency: startSceneModel, showFinishButton: $showVisualizationView)
					.padding(.top, 50)
				Spacer()
				if showVisualizationView {
					VisualizationSolutionPathView(startSceneModel: self.startSceneModel)
						.background(Color.mm_background_tertiary)
						.transition(.move(edge: .bottom))
						.padding(.bottom)
				}
			}
		}
		.onReceive(self.startSceneModel.pathSolutionSubject, perform: { isShowPath in
			withAnimation {
				self.showVisualizationView = isShowPath
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
