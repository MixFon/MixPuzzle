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
	/// Нужно для вибрации при нажатии (учитывает настройку «Вибрация»)
	let settingsGameStorage: _SettingsGameStorage

	enum Router: Hashable {
		case toStart
		case toOprionts
		case toFindSolution
	}

    var body: some View {
        // TODO: Перенести в dependency
		MenuScene(viewModel: self.viewModel, materialsWorker: self.materialsWorker, settingsGameStorage: self.settingsGameStorage) { goTo in
			switch goTo {
			case .toStart:
				self.toStart = true
			case .toOprionts:
				self.toOprionts = true
			case .toFindSolution:
				self.toFindSolution = true
			}
		}
		// 3D-надписи недоступны VoiceOver, поэтому пункты меню — действиями самой сцены
		.accessibilityElement()
		.accessibilityLabel("MixPuzzle")
		.accessibilityAction(named: Text("mix.menu.play".localized)) { self.toStart = true }
		.accessibilityAction(named: Text("mix.menu.solution".localized)) { self.toFindSolution = true }
		.accessibilityAction(named: Text("mix.menu.settings".localized)) { self.toOprionts = true }
    }
}

extension MenuSceneWrapper: Equatable {
	nonisolated static func == (lhs: MenuSceneWrapper, rhs: MenuSceneWrapper) -> Bool {
		return true
	}
}

#Preview {
	MenuSceneWrapper(
		toStart: .constant(true),
		toOprionts: .constant(true),
		toFindSolution: .constant(true),
		viewModel: MenuViewModel(),
		materialsWorker: MaterialsWorker(),
		settingsGameStorage: MockSettingsGameStorage()
	)
}
