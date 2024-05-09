//
//  CollectionView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 09.05.2024.
//

import SwiftUI

struct SelectLevelView: View {
	private let items = Array(3...100)
	let currentLevel: Int
	@State var selectNumber: Int = 3
	
	var body: some View {
		ScrollView {
			LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))]) {
				ForEach(items, id: \.self) { item in
					NumberCell(number: item, isSelect: self.selectNumber == item, showLockIcon: item > currentLevel, selectNumber: $selectNumber)
				}
			}
			.padding()
		}
	}
}

struct NumberCell: View {
	let number: Int
	let isSelect: Bool
	let showLockIcon: Bool
	@Binding var selectNumber: Int
	
	var body: some View {
		Button {
			self.selectNumber = self.number
		} label: {
			TextNumberCell(number: number, isSelect: isSelect, showLockIcon: showLockIcon)
		}.disabled(showLockIcon)
	}
}

struct TextNumberCell: View {
	let number: Int
	let isSelect: Bool
	let showLockIcon: Bool
	
	var body: some View {
		Text("\(number)x\(number)")
			.frame(width: 70, height: 70)
			.background(isSelect ? Color.blue : .mm_background_secondary)
			.cornerRadius(10)
			.foregroundColor(isSelect ? .white : .mm_text_primary)
			.padding(5)
			.overlay(showLockIcon ? lockImage : nil, alignment: .bottomTrailing)
	}
	
	private var lockImage: some View {
		Image(systemName: "lock.shield.fill")
			.foregroundColor(.mm_danger)
			.padding(10)
	}
}

#Preview {
	let currentLavel = 5
	return SelectLevelView(currentLevel: currentLavel)
}
