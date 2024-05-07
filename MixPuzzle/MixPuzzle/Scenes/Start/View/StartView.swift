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
	/// Паблишер для обработки нажатия кнопки сохранить
	let saveSubject = PassthroughSubject<Void, Never>()
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
		.ignoresSafeArea()
    }
}

#Preview {
    let dependency = MockDependency()
    return StartView(dependency: dependency)
}
