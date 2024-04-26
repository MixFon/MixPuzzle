//
//  SettingsCubeView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 11.04.2024.
//

import SwiftUI
import Combine

final class SettingsCubeDependency: ObservableObject {
    @Published var sizeImage: Double
    @Published var colorLable: Color = .blue
    @Published var radiusImage: Double = 10
    @Published var radiusChamfer: Double = 1
    @Published var colorBackground: Color = .red
    @Published var isButtonActive: Bool = false
	
    private var cubeStorage: _SettingsCubeStorage
	private var cancellables = Set<AnyCancellable>()
	
    init(cubeStorage: _SettingsCubeStorage) {
        self.cubeStorage = cubeStorage
        self.sizeImage = cubeStorage.sizeImage
        self.colorLable = cubeStorage.colorLable
        self.radiusImage = cubeStorage.radiusImage
        self.radiusChamfer = cubeStorage.radiusChamfer
        self.colorBackground = cubeStorage.colorBackground
	}
    
    func saveChanges() {
        self.cubeStorage.sizeImage = self.sizeImage
        self.cubeStorage.colorLable = self.colorLable
        self.cubeStorage.radiusImage = self.radiusImage
        self.cubeStorage.radiusChamfer = self.radiusChamfer
        self.cubeStorage.colorBackground = self.colorBackground
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
					AnyView(SliderCellView(title: "Width Image", range: 50...100, radius: $dependecy.sizeImage)),
                    AnyView(ColorCellView(title: "Color Lable", selectedColor: $dependecy.colorLable)),
                    AnyView(ColorCellView(title: "Color Cube", selectedColor: $dependecy.colorBackground)),
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
    var sizeImage: Double = 50
    var colorLable: Color = .blue
    var radiusImage: Double = 10
    var radiusChamfer: Double = 1
    var colorBackground: Color = .red
}
