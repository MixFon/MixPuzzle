//
//  MenuViewWrapper.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 05.04.2024.
//

import SwiftUI

struct MenuSceneWrapper: View {
	
	@Binding var toStart: Bool
	@Binding var toOprionts: Bool
	@Binding var toFindSolution: Bool
	let viewModel: MenuViewModel
	let materialsWorker: _MaterialsWorker
	
	enum Router: Hashable {
		case toStart
		case toOprionts
		case toFindSolution
	}

    var body: some View {
        // TODO: Перенести в dependency
		MenuScene(viewModel: self.viewModel, materialsWorker: self.materialsWorker) { goTo in
			switch goTo {
			case .toStart:
				self.toStart = true
			case .toOprionts:
				self.toOprionts = true
			case .toFindSolution:
				self.toFindSolution = true
			}
		}
    }
}

extension MenuSceneWrapper: @preconcurrency Equatable {
	static func == (lhs: MenuSceneWrapper, rhs: MenuSceneWrapper) -> Bool {
		return true
	}
}

#Preview {
	MenuSceneWrapper(
		toStart: .constant(true),
		toOprionts: .constant(true),
		toFindSolution: .constant(true),
		viewModel: MenuViewModel(),
		materialsWorker: MaterialsWorker()
	)
}
