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
    
    private let dependency = Dependency()
    
    var body: some Scene {
        WindowGroup {
            MenuView(dependency: self.dependency)
        }
    }
}
