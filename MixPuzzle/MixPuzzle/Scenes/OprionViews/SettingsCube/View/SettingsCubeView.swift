//
//  SettingsCubeView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 11.04.2024.
//

import SwiftUI
import Combine

final class SettingsCubeModel: ObservableObject {
    @Published var texture: String
    @Published var sizeImage: Double
    @Published var colorLable: Color
    @Published var radiusImage: Double
    @Published var radiusChamfer: Double
	
    private var cubeStorage: _SettingsCubeStorage
	private var cancellables = Set<AnyCancellable>()
	
    init(cubeStorage: _SettingsCubeStorage) {
        self.cubeStorage = cubeStorage
        self.sizeImage = cubeStorage.sizeImage
        self.colorLable = cubeStorage.colorLable ?? .blue
        self.radiusImage = cubeStorage.radiusImage
        self.radiusChamfer = cubeStorage.radiusChamfer
        self.texture = cubeStorage.texture ?? ""
	}
    
    func saveChanges() {
        self.cubeStorage.texture = self.texture
        self.cubeStorage.sizeImage = self.sizeImage
        self.cubeStorage.colorLable = self.colorLable
        self.cubeStorage.radiusImage = self.radiusImage
        self.cubeStorage.radiusChamfer = self.radiusChamfer
    }
}

struct SettingsCubeView: View {
	
	let dependency: _Dependency
	@ObservedObject var model: SettingsCubeModel
	@State private var isShowSnackbar = false
	
	var body: some View {
		VStack {
			NavigationBar(title: "Cube".localized, tralingView: AnyView(
				ButtonNavigationBar(title: "Save".localized, action: {
                    self.model.saveChanges()
					isShowSnackbar = true
                })
            ))
            .padding()
			SettingsCubeWrapper(model: self.model, dependency: self.dependency)
				.id("setting_cube_static_id")
				.aspectRatio(contentMode: .fit)
				.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
				.background(Color.mm_background_secondary)
			ScrollView {
				OptionsSectionsView(title: "Cube".localized, cells: [
					AnyView(SliderCellView(title: "Image radius".localized, range: 0...(model.sizeImage / 2), value: $model.radiusImage)),
					AnyView(SliderCellView(title: "Chamfer radius".localized, range: 0...2, value: $model.radiusChamfer)),
					AnyView(SliderCellView(title: "Width image".localized, range: 200...400, value: $model.sizeImage)),
                    AnyView(ColorCellView(title: "Color lable".localized, selectedColor: $model.colorLable)),
                    AnyView(TexturePicker(title: "Textures".localized, selectedImage: $model.texture)),
				])
			}
			.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
			.padding()
		}
		.snackbar(isShowing: $isShowSnackbar, text: "mix.snackbar.saved".localized, style: .success, extraBottomPadding: 16)
		.background(Color.mm_background_secondary)
	}
}

#Preview {
    let settingsCubeDependtnsy = SettingsCubeModel(cubeStorage: MockSettingsCubeStorage())
	return SettingsCubeView(dependency: MockDependency(), model: settingsCubeDependtnsy)
}

final class MockSettingsCubeStorage: _SettingsCubeStorage {
    var texture: String? = "TerrazzoSlab018"
    var sizeImage: Double = 200
    var colorLable: Color? = .blue
    var radiusImage: Double = 50
    var radiusChamfer: Double = 1
}
