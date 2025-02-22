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
	@Published var countLights: Int
	@Published var isMotionEnabled: Bool
	@Published var isShadowEnabled: Bool
	
	private var lightStorage: any _SettingsLightStorage
	private var cancellables = Set<AnyCancellable>()
	
	init(lightStorage: any _SettingsLightStorage) {
		self.lightStorage = lightStorage
		self.lightType = lightStorage.lightType
		self.countLights = lightStorage.countLights
		self.isMotionEnabled = lightStorage.isMotionEnabled
		self.isShadowEnabled = lightStorage.isShadowEnabled
	}
	
	func saveChanges() {
		self.lightStorage.lightType = self.lightType
		self.lightStorage.countLights = self.countLights
		self.lightStorage.isMotionEnabled = self.isMotionEnabled
		self.lightStorage.isShadowEnabled = self.isShadowEnabled
	}
}

struct SettingsLightView: View {
	
	@ObservedObject var lightModel: SettingsLightModel
	@State private var isShowSnackbar = false
	
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
				OptionsSectionsView(title: "Asteroids", cells: [
//					AnyView(ToggleCellView(icon: "waveform.path", text: "Show Asteroids", isOn: $asteroidsModel.isShowAsteroids)),
//					AnyView(SliderCellView(title: "Asteroids Count", range: 0...200, radius: $asteroidsModel.asteroidsCount)),
//					AnyView(SliderCellView(title: "Radius Sphere Asteroids", range: 20...40, radius: $asteroidsModel.radiusSphere)),
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
