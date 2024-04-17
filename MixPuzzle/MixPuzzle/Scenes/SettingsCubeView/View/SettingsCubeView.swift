//
//  SettingsCubeView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 11.04.2024.
//

import SwiftUI
import Combine

class SettingsCubeDependency: ObservableObject {
	@Published var radiusImage: Double = 10
	@Published var chamferRadius: Double = 1
	@Published var isButtonActive: Bool = false
	
	private var cancellables: Set<AnyCancellable> = []
	
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
			NavigationBar(title: "Settings Cubes")
				.padding()
			SettingsCubeWrapper(dependency: dependecy)
				.aspectRatio(contentMode: .fit)
				.cornerRadius(10)
				.background(Color.mm_background_secondary)
			Button {
				
			} label: {
				Image(systemName: "sdcard")
					.resizable()
					.scaledToFit()
					.frame(width: 32, height: 32)
				
			}
			.disabled(dependecy.isButtonActive)

			ScrollView {
				OptionsSectionsView(title: "Cube", cells: [
					AnyView(SliderCellView(title: "Image Radius", range: 0...25, radius: $dependecy.radiusImage)),
					AnyView(SliderCellView(title: "Chamfer Radius", range: 0...2, radius: $dependecy.chamferRadius)),
				])
			}
			.padding()
			Spacer()
		}
		.background(Color.mm_background_secondary)
	}
}

#Preview {
	SettingsCubeView()
}
