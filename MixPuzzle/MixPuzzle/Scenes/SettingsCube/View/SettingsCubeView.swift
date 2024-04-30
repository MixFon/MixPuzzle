//
//  SettingsCubeView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 11.04.2024.
//

import SwiftUI
import Combine

final class SettingsCubeDependency: ObservableObject {
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
	
	@ObservedObject var dependecy: SettingsCubeDependency
	@State private var isShowSnackbar = false
	
	var body: some View {
		VStack {
			NavigationBar(title: "Settings Cubes", tralingView: AnyView(
                SaveButtonNavigationBar(action: {
                    self.dependecy.saveChanges()
					isShowSnackbar = true
                })
            ))
            .padding()
			SettingsCubeWrapper(dependency: dependecy)
				.aspectRatio(contentMode: .fit)
				.cornerRadius(10)
				.background(Color.mm_background_secondary)
			ScrollView {
				OptionsSectionsView(title: "Cube", cells: [
					AnyView(SliderCellView(title: "Image Radius", range: 0...(dependecy.sizeImage / 2), radius: $dependecy.radiusImage)),
					AnyView(SliderCellView(title: "Chamfer Radius", range: 0...2, radius: $dependecy.radiusChamfer)),
					AnyView(SliderCellView(title: "Width Image", range: 200...400, radius: $dependecy.sizeImage)),
                    AnyView(ColorCellView(title: "Color Lable", selectedColor: $dependecy.colorLable)),
                    AnyView(TexturePicker(title: "Textures", selectedImage: $dependecy.texture)),
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
    let settingsCubeDependtnsy = SettingsCubeDependency(cubeStorage: MockSettingsCubeStorage())
    return SettingsCubeView(dependecy: settingsCubeDependtnsy)
}

final class MockSettingsCubeStorage: _SettingsCubeStorage {
    var texture: String? = "TerrazzoSlab018_COL"
    var sizeImage: Double = 200
    var colorLable: Color? = .blue
    var radiusImage: Double = 50
    var radiusChamfer: Double = 1
}
