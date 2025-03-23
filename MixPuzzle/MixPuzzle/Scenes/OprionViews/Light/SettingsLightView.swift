//
//  Light.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 22.02.2025.
//

import SwiftUI
import Combine

final class SettingsLightModel: ObservableObject {
	
	@Published var lightType: LightType
	@Published var countLights: Double
	@Published var isMotionEnabled: Bool
	@Published var isShadowEnabled: Bool
	
	private var lightStorage: any _SettingsLightStorage
	private var cancellables = Set<AnyCancellable>()
	
	init(lightStorage: any _SettingsLightStorage) {
		self.lightStorage = lightStorage
		self.lightType = lightStorage.lightType
		self.countLights = Double(lightStorage.countLights)
		self.isMotionEnabled = lightStorage.isMotionEnabled
		self.isShadowEnabled = lightStorage.isShadowEnabled
	}
	
	func saveChanges() {
		self.lightStorage.lightType = self.lightType
		self.lightStorage.countLights = Int(self.countLights)
		self.lightStorage.isMotionEnabled = self.isMotionEnabled
		self.lightStorage.isShadowEnabled = self.isShadowEnabled
	}
}

struct SettingsLightView: View {
	
	@ObservedObject var lightModel: SettingsLightModel
	@State private var isShowSnackbar = false
	private let lightTypes: [LightType] = LightType.allCases
	
    var body: some View {
		VStack {
			NavigationBar(title: self.navigationBarTitle, tralingView: AnyView(
				SaveButtonNavigationBar(action: {
					self.lightModel.saveChanges()
					self.isShowSnackbar = true
				})
			))
			.padding()
			ScrollView {
				OptionsSectionsView(title: self.sectionName, cells: cellsOfSection)
			}
			.animation(.default, value: self.lightModel.lightType)
			.cornerRadius(16)
			.padding()
		}
		.snackbar(isShowing: $isShowSnackbar, text: "The data has been saved successfully.", style: .success, extraBottomPadding: 16)
		.background(Color.mm_background_secondary)
    }
	
	private var cellsOfSection: [AnyView] {
		var cells: [AnyView] = [AnyView(SelectSizePicker(selectedSize: $lightModel.lightType, numbersSize: self.lightTypes))]
		switch self.lightModel.lightType {
		case .spot, .omni:
			cells.append(contentsOf: [
				AnyView(ToggleCellView(icon: "move.3d", text: self.nameIsMovingCell, isOn: $lightModel.isMotionEnabled)),
				AnyView(ToggleCellView(icon: "shadow", text: self.nameIsShadowCell, isOn: $lightModel.isShadowEnabled)),
				AnyView(SliderCellView(title: self.nameNamberOfLightsCell, range: 1...Double(lightTypes.count), value: $lightModel.countLights)),
			])
		case .directional:
			cells.append(contentsOf: [
				AnyView(ToggleCellView(icon: "move.3d", text: self.nameIsMovingCell, isOn: $lightModel.isMotionEnabled)),
				AnyView(ToggleCellView(icon: "shadow", text: self.nameIsShadowCell, isOn: $lightModel.isShadowEnabled)),
			])
		case .ambient, .undefined:
			break
		}
		return cells
	}
	private let nameIsMovingCell = String(localized: "Is Moving", comment: "Name of cell in light settings screen")
	private let nameIsShadowCell = String(localized: "Is Shadow", comment: "Name of cell in light settings screen")
	private let nameNamberOfLightsCell = String(localized: "Number of light sources", comment: "Name of cell in light settings screen")

	private let sectionName = String(localized: "Light Source", comment: "Name of section in light settings screen")
	private let navigationBarTitle = String(localized: "Lighting", comment: "Title in navigation bar in light settings screen")
}

#Preview {
	let mockSettingsLightModel = SettingsLightModel(lightStorage: MockSettingsLightStorage())
	return SettingsLightView(lightModel: mockSettingsLightModel)
}
