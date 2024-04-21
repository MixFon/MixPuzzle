//
//  SettingsCubeView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 11.04.2024.
//

import SwiftUI
import Combine

final class SettingsCubeDependency: ObservableObject {
    @Published var sizeImage: Double = 50
    @Published var lableColor: Color = .blue
    @Published var radiusImage: Double = 10
    @Published var chamferRadius: Double = 1
    @Published var isButtonActive: Bool = false
    @Published var backgroundColor: Color = .red
	
	private var cancellables = Set<AnyCancellable>()
	
	init() {
		// Создаём поток, который срабатывает при изменении любого из двух свойств
		Publishers.CombineLatest($radiusImage, $chamferRadius)
			.map { radiusImage, chamferRadius in
				// Проверяем условия активации кнопки
				radiusImage > 10 || chamferRadius > 1
			}
			.assign(to: \.isButtonActive, on: self)
			.store(in: &cancellables)
	}
}

struct SettingsCubeView: View {
	
	@ObservedObject var dependecy: SettingsCubeDependency = SettingsCubeDependency()
	
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	
	var body: some View {
		VStack {
			NavigationBar(title: "Settings Cubes", tralingView: AnyView(
                SaveButtonNavigationBar(action: { print("Save")})
                    .disabled(false)
            ))
            .padding()
			SettingsCubeWrapper(dependency: dependecy)
				.aspectRatio(contentMode: .fit)
				.cornerRadius(10)
				.background(Color.mm_background_secondary)
			ScrollView {
				OptionsSectionsView(title: "Cube", cells: [
					AnyView(SliderCellView(title: "Image Radius", range: 0...(dependecy.sizeImage / 2), radius: $dependecy.radiusImage)),
					AnyView(SliderCellView(title: "Chamfer Radius", range: 0...2, radius: $dependecy.chamferRadius)),
					AnyView(SliderCellView(title: "Width Image", range: 50...100, radius: $dependecy.sizeImage)),
                    AnyView(ColorCellView(title: "Color Lable", selectedColor: $dependecy.lableColor)),
                    AnyView(ColorCellView(title: "Color Cube", selectedColor: $dependecy.backgroundColor)),
				])
			}
            .cornerRadius(16)
			.padding()
		}
		.background(Color.mm_background_secondary)
	}
}

#Preview {
	SettingsCubeView()
}
