//
//  Light.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 22.02.2025.
//

import SwiftUI

struct LightView: View {
	
	let dependency: _Dependency
	
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
	let mockDependecy = MockDependency()
	return LightView(dependency: mockDependecy)
}
