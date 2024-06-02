//
//  StartSceneWrapper.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 05.04.2024.
//

import SwiftUI
import MFPuzzle
import Foundation

/// Обертка для вредставления основной игры
struct StartSceneWrapper: View {
    let dependency: _Dependency
	let startSceneModel: StartSceneModel
	
	private let startFactory = StartFactory()
	
	var body: some View {
		self.startFactory.configure(dependency: self.dependency, startSceneModel: self.startSceneModel)
	}
}

extension StartSceneWrapper: Equatable {
	static func == (lhs: StartSceneWrapper, rhs: StartSceneWrapper) -> Bool {
		return true
	}
}

/// Обертка для представления возможных решений
struct TargetSelectSceneWrapper: View {
	let matrix: Matrix
	let dependency: _Dependency
	let startSceneModel: StartSceneModel = StartSceneModel()
	
	private let startFactory = StartFactory()
	
	var body: some View {
		self.startFactory.configure(matrix: self.matrix, dependency: self.dependency, startSceneModel: self.startSceneModel)
	}
}

extension TargetSelectSceneWrapper: Equatable {
	static func == (lhs: TargetSelectSceneWrapper, rhs: TargetSelectSceneWrapper) -> Bool {
		return true
	}
}

/// Обертка для показа решения головоломки
struct VisualizationSolutionWrapper: View {
	let matrix: Matrix
	let dependency: _Dependency
	let startSceneModel: StartSceneModel
	
	private let startFactory = StartFactory()
	
	var body: some View {
		self.startFactory.configureShowPathCompasses(matrix: self.matrix, dependency: self.dependency, startSceneModel: self.startSceneModel)
	}
}

extension VisualizationSolutionWrapper: Equatable {
	static func == (lhs: VisualizationSolutionWrapper, rhs: VisualizationSolutionWrapper) -> Bool {
		return true
	}
}
