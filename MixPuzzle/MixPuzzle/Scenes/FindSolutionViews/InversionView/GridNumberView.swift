//
//  NumberGridView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 18.05.2025.
//

import SwiftUI

struct NumberGridView: View {
	
	let values: [String]
	
	// Определяем адаптивную grid layout
	private var columns: [GridItem] {
		[GridItem(.adaptive(minimum: 60, maximum: 100), spacing: 10)]
	}
	
	var body: some View {
		LazyVGrid(columns: columns, spacing: 8) {
			ForEach(values.indices, id: \.self) { index in
				Text(values[index])
					.font(.system(size: 20, weight: .medium, design: .rounded))
					.padding(.horizontal, 8)
					.padding(.vertical, 4)
					.background(Color.mm_green.opacity(0.2))
					.cornerRadius(10)
					.overlay(
						RoundedRectangle(cornerRadius: 10)
							.stroke(Color.mm_green, lineWidth: 2)
					)
			}
		}
		.padding()
		.overlay(
			RoundedRectangle(cornerRadius: 16)
				.stroke(Color.mm_divider_opaque, lineWidth: 3) // Зеленая обводка
		)
	}
}

struct NumberGridView_Previews: PreviewProvider {
	static var previews: some View {
		return NumberGridView(values: ["10-10", "1-10", "1-10", "1-10", "1-10", "1-10", "1-10", "1-10"])
	}
}
