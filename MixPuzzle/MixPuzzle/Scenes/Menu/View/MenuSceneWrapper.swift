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
	
	enum Router: Hashable {
		case toStart
		case toOprionts
		case toFindSolution
	}

    var body: some View {
        // TODO: Перенести в dependency
        MenuScene(materialsWorker: MaterialsWorker()) { goTo in
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

extension MenuSceneWrapper: Equatable {
	static func == (lhs: MenuSceneWrapper, rhs: MenuSceneWrapper) -> Bool {
		return true
	}
}

@available(iOS 17.0, *)
#Preview {
	@Previewable @State var toStart: Bool = false
	@Previewable @State var toOprionts: Bool = false
	@Previewable @State var toFindSolution: Bool = false
	return MenuSceneWrapper(toStart: $toStart, toOprionts: $toOprionts, toFindSolution: $toFindSolution)
}
