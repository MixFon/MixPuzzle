//
//  ManualFillingView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 25.05.2024.
//

import SwiftUI
	
struct ManualFillingView: View {
	let dependency: _Dependency
	
	@State private var matrix: [[String]] = Array(repeating: Array(repeating: "", count: 4), count: 4)
	@State private var isShowSnackbar = false

	var body: some View {
		VStack {
			NavigationBar(title: "Manual filling", tralingView: AnyView(
				SaveButtonNavigationBar(action: {
					printMatrix()
				})
			))
			.padding()
			FillingMatrixView(matrix: $matrix)
			Spacer()
		}
		.snackbar(isShowing: $isShowSnackbar, text: "The data has been saved successfully.", style: .success, extraBottomPadding: 16)
	}
	
	private func printMatrix() {
		for row in matrix {
			print(row)
		}
	}
	
	private func checkMatrix() {
		
	}
	
	private func showSnackbarError() {
		
	}
	
	private func showSnackbarSuccesee() {
		
	}
}

struct FillingMatrixView: View {
	
	@Binding var matrix: [[String]]
	
	var body: some View {
		VStack(spacing: 20) {
			ForEach(0..<matrix.count, id: \.self) { row in
				HStack(spacing: 20) {
					ForEach(0..<matrix.count, id: \.self) { column in
						FillingMatrixElementView(text: $matrix[row][column])
					}
				}
			}
		}
		.padding()
	}
}

struct FillingMatrixElementView: View {
	@Binding var text: String
	
	var body: some View {
		TextField("0", text: $text)
		.frame(width: 50, height: 50)
		.keyboardType(.numberPad)
			.multilineTextAlignment(.center)
			.foregroundColor(Color.mm_text_primary)
			.clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
			.limitedText($text, to: 2)
			.overlay(
				RoundedRectangle(cornerRadius: 10)
					.stroke(Color.mm_divider_opaque, lineWidth: 2)
			)
	}
}


#Preview {
	let dependency = MockDependency()
	return ManualFillingView(dependency: dependency)
}
