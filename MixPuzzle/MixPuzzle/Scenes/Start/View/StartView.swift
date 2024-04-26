//
//  StartView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 22.02.2024.
//

import SwiftUI
import MFPuzzle

struct StartView: View {
    
    let dependency: _Dependency
	
    var body: some View {
		ZStack {
            StartSceneWrapper(dependency: self.dependency)
				.equatable() // Отключение обновления сцены
			VStack {
				StartScoreView()
				Spacer()
			}
		}
    }
}

#Preview {
    let dependency = MockDependency()
    return StartView(dependency: dependency)
}
