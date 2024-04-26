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
        self.cubeStorage.sizeImage = self.sizeImage
        self.cubeStorage.radiusImage = self.radiusImage
        self.cubeStorage.radiusChamfer = self.radiusChamfer
        self.cubeStorage.colorLable = self.colorLable
    }
}

struct SettingsCubeView: View {
	
	@ObservedObject var dependecy: SettingsCubeDependency
	
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	
	var body: some View {
		VStack {
			NavigationBar(title: "Settings Cubes", tralingView: AnyView(
                SaveButtonNavigationBar(action: {
                    self.dependecy.saveChanges()
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
				])
			}
            .cornerRadius(16)
			.padding()
		}
		.background(Color.mm_background_secondary)
	}
}

#Preview {
    let settingsCubeDependtnsy = SettingsCubeDependency(cubeStorage: MockSettingsCubeStorage())
    return SettingsCubeView(dependecy: settingsCubeDependtnsy)
}

final class MockSettingsCubeStorage: _SettingsCubeStorage {
    var texture: String? = "TerrazzoSlab018_COL_1K_SPECULAR"
    var sizeImage: Double = 200
    var colorLable: Color? = .blue
    var radiusImage: Double = 50
    var radiusChamfer: Double = 1
}
