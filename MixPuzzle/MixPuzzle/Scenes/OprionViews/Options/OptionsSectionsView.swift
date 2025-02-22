//
//  OptionsSectionsView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 09.04.2024.
//

import SwiftUI
import Foundation

struct OptionsSectionsView: View {
	let title: String
	let cells: [AnyView]
	
	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text(title)
				.font(.title2)
				.bold()
				.foregroundStyle(Color.mm_text_primary)
			VStack(spacing: 10) {
				ForEach(cells.indices, id: \.self) { index in
					self.cells[index]
					if index != self.cells.indices.last {
						DividerView()
					}
				}
			}
		}
		.padding(20)
		.background(Color.mm_background_tertiary)
		.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
	}
}

struct CellView: View, Identifiable {
	let id = UUID()
	let icon: String
	let text: String
	let action: ()->()
	
	var body: some View {
		Button(action: action, label: {
			HStack {
				Image(systemName: icon)
					.foregroundStyle(Color.mm_tint_primary)
				Text(text)
					.foregroundStyle(Color.mm_text_primary)
				Spacer()
				Image(systemName: "chevron.right")
					.foregroundStyle(Color.mm_tint_icons)
			}
		})
		.buttonStyle(.plain)
	}
}

struct SliderCellView: View, Identifiable {
	let id = UUID()
	let title: String
	let range: ClosedRange<Double>

	@Binding var value: Double
	
	var body: some View {
		VStack {
			HStack {
				Text(self.title)
					.foregroundStyle(Color.mm_text_primary)
				Spacer()
				Text("\(value, specifier: "%.f")")
					.foregroundStyle(Color.mm_text_primary)
			}
			Slider(value: $value, in: range, onEditingChanged: { editing in
				debugPrint(editing)
			})
			.accentColor(Color.mm_green) // Изменяем цвет трека
		}
	}
}

struct ToggleCellView: View, Identifiable {
	let id = UUID()
	let icon: String
	let text: String
	
	@Binding var isOn: Bool
	
	var body: some View {
		HStack {
			Image(systemName: icon)
				.buttonStyle(.plain)
				.foregroundStyle(Color.mm_tint_primary)
			Spacer()
			Toggle(text, isOn: $isOn)
				.tint(Color.mm_tint_primary)
				.foregroundStyle(Color.mm_text_primary)
		}
	}
}

struct ColorCellView: View, Identifiable {
	let id = UUID()
    var colors: [Color] = [.red, .green, .blue, .orange, .purple]

    let title: String
    @Binding var selectedColor: Color
	
	var body: some View {
		VStack(alignment: .leading) {
			Text(title)
			ScrollView(.horizontal) {
				HStack(alignment: .center, spacing: 16) {
                    ColorPicker("Colors", selection: $selectedColor)
					ForEach(colors, id: \.self) { color in
						Button {
                            self.selectedColor = color
						} label: {
							Rectangle()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(color)
								.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            
						}
						.buttonStyle(.plain)
                    }
                }
            }
		}
	}
}

struct TexturePicker: View {
    let id = UUID()
    let title: String
    let images = [
        "coral_fort_wall",
        "shfsaida",
        "sbbihkp",
        "rock_face_03",
        "WickerWeavesBrownRattan001",
        "StoneBricksSplitface001",
        "MetalZincGalvanized001",
        "GroundWoodChips001",
        "TilesCeramicHerringbone002",
        "GroundSand005",
        "FabricLeatherCowhide001",
        "GroundDirtRocky020",
        "GroundGrassGreen002",
        "MetalCorrodedHeavy001",
        "BricksDragfacedRunning008",
        "MetalCastRusted001",
        "TerrazzoSlab028",
        "TerrazzoSlab018",
        "TilesMosaicPennyround001",
        "VeneerWhiteOakRandomMatched001",
        "PlasticABSWorn001",
        "MetalGoldPaint002",
        "BoucleBubblyRows001",
        "PlasterPlain001",
        "StuccoRoughCast001",
        "RoofShinglesOld002",
        "WaterDropletsMixedBubbled001",
        "TilesSquarePoolMixed001",
		"Lava004_1K-JPG",
        "WoodPlanksWorn001",
        "TilesTravertine001",
    ]
    
    @Binding var selectedImage: String
    
    var body: some View {
        VStack(alignment: .leading){
            Text(title)
                .foregroundStyle(Color.mm_text_primary)
            // Создаем горизонтальный ScrollView для прокрутки изображений
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(images, id: \.self) { imageName in
                        Button(action: {
                            self.selectedImage = imageName
                        }) {
							TextureImage(imageName: imageName + "_COL", isSelectedImage: self.selectedImage == imageName)
                        }
						.buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
    }
}

struct TextureImage: View {
	let imageName: String
	let isSelectedImage: Bool
	var body: some View {
		Image(imageName)
			.resizable()
			.scaledToFill()
			.clipped()
			.frame(width: 70, height: 70)
			.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
			.shadow(radius: 5)
			.overlay(
				RoundedRectangle(cornerRadius: 10)
					.stroke(Color.blue, lineWidth: isSelectedImage  ? 4 : 0)
			)
	}
}

struct DividerView: View {
	var body: some View {
		Divider()
			.padding(.leading, 30)
			.foregroundColor(Color.mm_text_secondary)
	}
}

@available(iOS 17.0, *)
#Preview {
	@Previewable @State var radius: Double = 10.0
	@Previewable @State var isOn: Bool = false
	@Previewable @State var selectedColor: Color = .red
	@Previewable @State var selectedImage = "TerrazzoSlab028_COL_1K_SPECULAR"
	return VStack {
		OptionsSectionsView(title: "Hello", cells: [
			AnyView(CellView(icon: "plus", text: "Hello", action: { debugPrint(1) })),
			AnyView(CellView(icon: "checkmark", text: "word", action: { debugPrint(2) })),
		])
		.padding()
		OptionsSectionsView(title: "Two", cells: [
			AnyView(CellView(icon: "plus", text: "Hello", action: { debugPrint(1) })),
			AnyView(CellView(icon: "checkmark", text: "word", action: { debugPrint(2) })),
			AnyView(CellView(icon: "checkmark", text: "text text", action: { debugPrint(2) })),
		])
		.padding()
		OptionsSectionsView(title: "Two", cells: [
			AnyView(SliderCellView(title: "Hello", range: 0...30, value: $radius)),
			AnyView(ToggleCellView(icon: "checkmark", text: "text text", isOn: $isOn)),
            AnyView(ColorCellView(title: "Trtb", selectedColor: $selectedColor)),
            AnyView(TexturePicker(title: "Textures", selectedImage: $selectedImage))
		])
		.padding()
		Spacer()
	}
	.background(Color.mm_background_secondary)
}
