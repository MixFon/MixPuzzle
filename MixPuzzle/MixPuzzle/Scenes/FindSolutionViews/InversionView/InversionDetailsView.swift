//
//  InversionDetailsView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 22.05.2025.
//

import SwiftUI
import MFPuzzle

struct InversionDetailsView: View {
	
	@State private var matrix: Matrix
	@State private var selectedSize: Int
	private let checker: _Checker
	private let matrixWorker: _MatrixWorker
	init(checker: _Checker, matrixWorker: _MatrixWorker) {
		let selectedSize = 3
		self.selectedSize = selectedSize
		self.matrix = matrixWorker.createMatrixRandom(size: selectedSize)
		self.checker = checker
		self.matrixWorker = matrixWorker
	}
	
	private let numbersSize = Array(3...5)

    var body: some View {
		VStack {
			NavigationBar(title: "Inversions".localized, tralingView: nil)
				.padding(.horizontal)
				.padding(.top)
			SelectSizePicker(selectedSize: $selectedSize, numbersSize: numbersSize)
				.padding(.horizontal)
				.padding(.top)
			buttonViews
			ScrollView {
				MatrixView(matrix: self.$matrix, checker: self.checker)
			}
			.padding(.horizontal)
			Spacer()
		}
		.onChange(of: self.selectedSize, perform: { newValue in
			self.matrix = self.matrixWorker.createMatrixRandom(size: newValue)
		})
		.background(Color.mm_background_secondary)
    }
	
	private var buttonViews: some View {
		HStack {
			Button {
				self.matrixWorker.changesParityInvariant(matrix: &self.matrix)
				self.matrix = matrix
				print(matrix)
			} label: {
				Text("Изменить")
					.font(.callout)
					.foregroundColor(Color.white)
					.padding(.horizontal, 20)
					.padding(.vertical, 10)
					.background(Color.mm_tint_icons)
					.cornerRadius(10)
					.shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 2)
			}
			.frame(maxWidth: .infinity, alignment: .center)
			Button {
				
			} label: {
				Text("Поменять")
					.font(.callout)
					.foregroundColor(Color.white)
					.padding(.horizontal, 20)
					.padding(.vertical, 10)
					.background(Color.mm_tint_icons)
					.cornerRadius(10)
					.shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 2)
			}
			.frame(maxWidth: .infinity, alignment: .center)
		}
			
	}
}

#Preview {
	InversionDetailsView(checker: MockChecker(), matrixWorker: MockMatrixWorker())
}
