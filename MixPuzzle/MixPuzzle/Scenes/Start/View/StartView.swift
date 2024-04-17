//
//  StartView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 22.02.2024.
//

import SwiftUI
import MFPuzzle

struct StartView: View {
	
    var body: some View {
		ZStack {
			StartSceneWrapper()
				.equatable() // Отключение обновления сцены
			VStack {
				StartScoreView()
				Spacer()
			}
		}
    }
}

#Preview {
    return StartView()
}
