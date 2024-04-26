//
//  ImagePicker.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 26.04.2024.
//

import SwiftUI

struct ImagePicker: View {
    // Имена изображений, добавленные в Asset Catalog
    let images = ["TerrazzoSlab028_COL_1K_SPECULAR", "TerrazzoSlab028_COL_1K_SPECULAR", "TerrazzoSlab018_COL_1K_SPECULAR", "BricksReclaimedWhitewashedOffset001_COL_1K_METALNESS", "TerrazzoSlab018_IDMAP_1K_SPECULAR","TerrazzoSlab018_IDMAP_1K_SPECULAR", "TerrazzoSlab018_IDMAP_1K_SPECULAR"]
    
    // Состояние для хранения текущего выбранного изображения
    @State private var selectedImage: String?

    var body: some View {
        VStack {
            // Показываем выбранное изображение
            if let selectedImage = selectedImage {
                Image(selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }

            // Создаем кнопки для выбора изображения
            HStack {
                ForEach(images, id: \.self) { imageName in
                    Button(action: {
                        // При нажатии кнопки обновляем выбранное изображение
                        self.selectedImage = imageName
                    }) {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .border(Color.blue, width: self.selectedImage == imageName ? 3 : 0)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ImagePicker()
}
