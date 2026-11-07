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
	@State private var tab: CubeSettingsTab = .material

	var body: some View {
		VStack(spacing: 0) {
			NavigationBar(title: "Cube".localized, tralingView: AnyView(
				Button {
					self.model.saveChanges()
					self.isShowSnackbar = true
				} label: {
					Image(systemName: "checkmark")
						.font(.body.weight(.bold))
						.foregroundStyle(Color.white)
						.frame(width: 44, height: 44)
						.background(Color.mm_tint_secondary)
						.clipShape(Circle())
				}
				.buttonStyle(.plain)
				.accessibilityLabel("Save".localized)
			))
			.padding(.horizontal)
			.padding(.vertical, 8)
			SettingsCubeWrapper(model: self.model, dependency: self.dependency)
				.id("setting_cube_static_id")
				.aspectRatio(contentMode: .fit)
			VStack(spacing: 16) {
				Capsule()
					.fill(Color.mm_text_secondary.opacity(0.5))
					.frame(width: 36, height: 5)
				CubeTabPicker(selected: self.$tab)
				ScrollView {
					self.tabContent
						.padding(.bottom, 24)
				}
			}
			.padding(.top, 10)
			.padding(.horizontal, 16)
			.frame(maxHeight: .infinity, alignment: .top)
			.background(Color.mm_background_tertiary)
			.clipShape(UnevenTopRoundedRectangle(radius: 28))
			.ignoresSafeArea(edges: .bottom)
		}
		.snackbar(isShowing: $isShowSnackbar, text: "mix.snackbar.saved".localized, style: .success, extraBottomPadding: 16)
		.background(Color.mm_background_secondary)
	}

	@ViewBuilder
	private var tabContent: some View {
		switch self.tab {
		case .material:
			LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
				ForEach(TexturePicker.images, id: \.self) { name in
					TextureCard(
						name: name,
						isSelected: self.model.texture == name
					) {
						self.model.texture = name
					}
				}
			}
		case .number:
			VStack(spacing: 16) {
				ColorCellView(title: "Color lable".localized, selectedColor: self.$model.colorLable)
					.foregroundStyle(Color.mm_text_primary)
				SliderCellView(title: "Width image".localized, range: 200...400, value: self.$model.sizeImage)
				SliderCellView(title: "Image radius".localized, range: 0...(self.model.sizeImage / 2), value: self.$model.radiusImage)
			}
		case .shape:
			SliderCellView(title: "Chamfer radius".localized, range: 0...2, value: self.$model.radiusChamfer)
		}
	}
}

/// Вкладки настроек кубика
enum CubeSettingsTab: CaseIterable {
	case material
	case number
	case shape

	var title: String {
		switch self {
		case .material:
			return String(localized: "mix.cube.tab.material", comment: "Tab in cube settings")
		case .number:
			return String(localized: "mix.cube.tab.number", comment: "Tab in cube settings")
		case .shape:
			return String(localized: "mix.cube.tab.shape", comment: "Tab in cube settings")
		}
	}
}

/// Переключатель вкладок в стиле сегментов
private struct CubeTabPicker: View {
	@Binding var selected: CubeSettingsTab

	var body: some View {
		HStack(spacing: 4) {
			ForEach(CubeSettingsTab.allCases, id: \.self) { tab in
				Button {
					withAnimation(.easeInOut(duration: 0.2)) {
						self.selected = tab
					}
				} label: {
					Text(tab.title)
						.font(.subheadline.weight(tab == self.selected ? .semibold : .regular))
						.foregroundStyle(tab == self.selected ? Color.mm_text_primary : Color.mm_text_secondary)
						.frame(maxWidth: .infinity, minHeight: 40)
						.background(tab == self.selected ? Color.mm_background_tertiary : Color.clear)
						.clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
				}
				.buttonStyle(.plain)
				.accessibilityAddTraits(tab == self.selected ? .isSelected : [])
			}
		}
		.padding(4)
		.background(Color.mm_background_secondary)
		.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
	}
}

/// Карточка текстуры с названием
private struct TextureCard: View {
	let name: String
	let isSelected: Bool
	let action: () -> Void

	var body: some View {
		Button(action: self.action) {
			VStack(alignment: .leading, spacing: 0) {
				Color.clear
					.frame(height: 68)
					.overlay(
						Image(self.name + "_COL")
							.resizable()
							.scaledToFill()
					)
					.clipped()
				Text(OptionsViewModel.readableTextureName(self.name))
					.font(.caption.weight(.semibold))
					.foregroundStyle(Color.mm_text_primary)
					.lineLimit(1)
					.minimumScaleFactor(0.7)
					.padding(.horizontal, 10)
					.padding(.vertical, 8)
			}
			.background(Color.mm_background_secondary)
			.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
			.overlay(
				RoundedRectangle(cornerRadius: 16, style: .continuous)
					.stroke(self.isSelected ? Color.mm_tint_secondary : Color.clear, lineWidth: 2)
			)
		}
		.buttonStyle(.plain)
		.accessibilityAddTraits(self.isSelected ? .isSelected : [])
	}
}

/// Скругление только верхних углов (UnevenRoundedRectangle доступен с iOS 16)
private struct UnevenTopRoundedRectangle: Shape {
	let radius: CGFloat

	func path(in rect: CGRect) -> Path {
		Path(UIBezierPath(
			roundedRect: rect,
			byRoundingCorners: [.topLeft, .topRight],
			cornerRadii: CGSize(width: self.radius, height: self.radius)
		).cgPath)
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
