//
//  ContentView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 20.02.2024.
//

import Combine
import SwiftUI
import SceneKit
import MFPuzzle

final class MenuViewModel: ObservableObject {
	let floorAnimationSubject = PassthroughSubject<MenuScene.AnimationComand, Never>()
}

final class MenuViewRouter: ObservableObject {
	
	@Published var toStart: Bool = false
	@Published var toOprionts: Bool = false
	@Published var toFindSolution: Bool = false
}

struct MenuView: View {
    
    let dependency: _Dependency
	@ObservedObject private var router = MenuViewRouter()
	@ObservedObject private var viewModel = MenuViewModel()
	
	var body: some View {
		MenuSceneWrapper(toStart: $router.toStart, toOprionts: $router.toOprionts, toFindSolution: $router.toFindSolution, viewModel: self.viewModel)
			.fullScreenCover(isPresented: self.$router.toStart) {
				StartView(dependency: self.dependency)
			}
			.fullScreenCover(isPresented: self.$router.toOprionts) {
				OptionsView(dependency: self.dependency)
			}
			.fullScreenCover(isPresented: self.$router.toFindSolution) {
				ChooseMethodView(dependency: self.dependency)
			}
			.onAppear {
				self.viewModel.floorAnimationSubject.send(.start)
			}
			.onDisappear {
				self.viewModel.floorAnimationSubject.send(.stop)
			}
			.onChange(of: self.router.toStart) { newValue in
				if newValue {
					self.viewModel.floorAnimationSubject.send(.stop)
				} else {
					self.viewModel.floorAnimationSubject.send(.start)
				}
			}
			.edgesIgnoringSafeArea(.all)
	}
}

#Preview {
    let dependency = MockDependency()
    return MenuView(dependency: dependency)
}

final class MockDependency: _Dependency {
	var puzzle: _Puzzle = MockPuzzle()
	var checker: _Checker = MockChecker()
	var workers: _Workers = MockWorkers()
    var settingsStorages: _SettingsStorage = MockSettingsStorage()
}

final class MockChecker: _Checker {
	func checkUniqueElementsMatrix(matrix: Matrix) -> Bool {
		return true
	}
	
	func isSquereMatrix(matrix: Matrix) -> Bool {
		return true
	}
	
	func checkSolution(matrix: Matrix, matrixTarget: MFPuzzle.Matrix) -> Bool {
		return true
	}
}

final class MockPuzzle: _Puzzle {
	func createPath(board: Board?) -> [Compass] {
		return []
	}
	
	func searchSolutionWithHeap(board: Board, boardTarget: Board) -> Board? {
		return nil
	}
	
	
}
