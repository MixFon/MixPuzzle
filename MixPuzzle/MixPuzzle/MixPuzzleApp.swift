//
//  MixPuzzleApp.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 20.02.2024.
//

import SwiftUI

@main
struct MixPuzzleApp: App {
	private let startFactory = StartFactory()
    var body: some Scene {
        WindowGroup {
            //MenuView()
			SettingsCubeView()
			//self.startFactory.configure(complition: {_ in })
        }
    }
}
