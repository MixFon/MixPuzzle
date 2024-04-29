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
	
	enum Router: Hashable {
		case toStart
		case toOprionts
	}

    var body: some View {
        // TODO: Перенести в dependency
        MenuScene(materialsWorker: MaterialsWorker()) { goTo in
			switch goTo {
			case .toStart:
				self.toStart = true
			case .toOprionts:
				self.toOprionts = true
			}
		}
    }
}

extension MenuSceneWrapper: Equatable {
	static func == (lhs: MenuSceneWrapper, rhs: MenuSceneWrapper) -> Bool {
		return true
	}
}

#Preview {
	@State var toStart: Bool = false
	@State var toOprionts: Bool = false
	return MenuSceneWrapper(toStart: $toStart, toOprionts: $toOprionts)
}
