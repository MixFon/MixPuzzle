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
	private let lightTypes: [LightType] = [.omni, .spot, .ambient, .directional]
	
    var body: some View {
		VStack {
			NavigationBar(title: "Settings Light", tralingView: AnyView(
				SaveButtonNavigationBar(action: {
					self.lightModel.saveChanges()
					self.isShowSnackbar = true
				})
			))
			.padding()
			ScrollView {
				OptionsSectionsView(title: "Light Source", cells: [
					AnyView(ToggleCellView(icon: "move.3d", text: "Is Moving", isOn: $lightModel.isMotionEnabled)),
					AnyView(ToggleCellView(icon: "shadow", text: "Is Shadow", isOn: $lightModel.isShadowEnabled)),
					AnyView(SliderCellView(title: "Lights Count", range: 1...Double(lightTypes.count), value: $lightModel.countLights)),
					AnyView(SelectSizePicker(selectedSize: $lightModel.lightType, numbersSize: self.lightTypes))
				])
			}
			.cornerRadius(16)
			.padding()
		}
		.snackbar(isShowing: $isShowSnackbar, text: "The data has been saved successfully.", style: .success, extraBottomPadding: 16)
		.background(Color.mm_background_secondary)
    }
}

#Preview {
	let mockSettingsLightModel = SettingsLightModel(lightStorage: MockSettingsLightStorage())
	return SettingsLightView(lightModel: mockSettingsLightModel)
}
