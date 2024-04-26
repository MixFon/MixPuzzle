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
			VStack(spacing: 8) {
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
		.cornerRadius(16)
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

	@Binding var radius: Double
	
	var body: some View {
		VStack {
			HStack {
				Text(self.title)
					.foregroundStyle(Color.mm_text_primary)
				Spacer()
				Text("\(radius, specifier: "%.f")")
					.foregroundStyle(Color.mm_text_primary)
			}
			Slider(value: $radius, in: range, onEditingChanged: { editing in
				print(editing)
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
                    ColorPicker("", selection: $selectedColor)
					ForEach(colors, id: \.self) { color in
						Button {
                            self.selectedColor = color
						} label: {
							Rectangle()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(color)
                                .cornerRadius(10)
                            
						}
                    }
                }
            }
		}
	}
}

struct TexturePicker: View {
    let id = UUID()
    let title: String
    let images = ["TerrazzoSlab028_COL_1K_SPECULAR", "TerrazzoSlab018_COL_1K_SPECULAR", "BricksReclaimedWhitewashedOffset001_COL_1K_METALNESS", "GroundDirtRocky020_COL_1K"]
    
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
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                                .clipped()
                                .frame(width: 70, height: 70)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: self.selectedImage == imageName ? 4 : 0)
                                )
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct DividerView: View {
	var body: some View {
		Divider()
			.padding(.leading, 30)
			.foregroundColor(Color.mm_text_secondary)
	}
}

#Preview {
    @State var radius: Double = 10.0
    @State var isOn: Bool = false
    @State var selectedColor: Color = .red
    @State var selectedImage = "TerrazzoSlab028_COL_1K_SPECULAR"
	return VStack {
		OptionsSectionsView(title: "Hello", cells: [
			AnyView(CellView(icon: "plus", text: "Hello", action: { print(1) })),
			AnyView(CellView(icon: "checkmark", text: "word", action: { print(2) })),
		])
		.padding()
		OptionsSectionsView(title: "Two", cells: [
			AnyView(CellView(icon: "plus", text: "Hello", action: { print(1) })),
			AnyView(CellView(icon: "checkmark", text: "word", action: { print(2) })),
			AnyView(CellView(icon: "checkmark", text: "text text", action: { print(2) })),
		])
		.padding()
		OptionsSectionsView(title: "Two", cells: [
			AnyView(SliderCellView(title: "Hello", range: 0...30, radius: $radius)),
			AnyView(ToggleCellView(icon: "checkmark", text: "text text", isOn: $isOn)),
            AnyView(ColorCellView(title: "Trtb", selectedColor: $selectedColor)),
            AnyView(TexturePicker(title: "Textures", selectedImage: $selectedImage))
		])
		.padding()
		Spacer()
	}
	.background(Color.mm_background_secondary)
}
