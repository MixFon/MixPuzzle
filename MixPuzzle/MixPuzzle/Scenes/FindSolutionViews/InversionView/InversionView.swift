//
//  InversionView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 19.05.2025.
//

import SwiftUI
import MFPuzzle

final class InversionViewRouter: ObservableObject {
	@Published var toDetails = false
}

struct InversionView: View {
	
	@StateObject private var router = InversionViewRouter()
	let checker: _Checker
	let matrixWorker: _MatrixWorker
	
	var body: some View {
		VStack {
			NavigationBar(title: "Inversions".localized, tralingView: nil)
				.padding(.horizontal)
				.padding(.top)
			Text("Verification algorithm")
				.font(.title3)
				.bold()
				.padding(.bottom, 8)
				.frame(maxWidth: .infinity)
				.multilineTextAlignment(.center)
			
			TabView {
				Group {
					self.pageOne
					self.pageTwo
					self.pageThree
					self.pageFour
				}
				.font(.callout)
				.foregroundStyle(Color.mm_text_primary)
				.padding(.top)
				.padding(.horizontal)
			}
			.tabViewStyle(.page(indexDisplayMode: .always))
			.indexViewStyle(.page(backgroundDisplayMode: .never))
			.frame(maxHeight: 336)
			.background(Color.mm_tint_icons)
			.clipShape(RoundedRectangle(cornerRadius: 16))
			Button("Details") {
				self.router.toDetails = true
			}
			.buttonStyle(MixButtonStyle())
			.frame(maxWidth: .infinity, alignment: .center)
			.padding()
			Spacer()
		}
		.fullScreenCover(isPresented: $router.toDetails) {
			InversionDetailsView(checker: self.checker, matrixWorker: self.matrixWorker)
		}
		.background(Color.mm_background_secondary)
    }
	
	func generateSnakeStack(n: Int) -> [(Int, Int)] {
		let matrix = (0..<n).map { i in
			let row = (0..<n).map { j in i * n + j }
			return i % 2 == 0 ? row : row.reversed()
		}

		let arr = matrix.flatMap { $0 }

		return (1..<arr.count).map { i in (arr[i - 1], arr[i]) }
	}
	
	private var pageOne: some View {
		VStack {
			VStack(alignment: .leading, spacing: 8) {
				Text("The puzzle can have no solution, that is, it can get a field state from which it is impossible to move to the solution state without breaking the rules of the game. To verify the existence of a puzzle solution, it is necessary to compare the equalities of inversions.")
				Text("**Inversion** is the number of pairs of elements that are in front of elements that have less importance than themselves.")
			}
			.padding()
			.background(
				RoundedRectangle(cornerRadius: 16)
					.fill(Color.mm_background_primary)
					.overlay(
						RoundedRectangle(cornerRadius: 16)
							.stroke(Color.mm_divider_opaque, lineWidth: 2)
					)
			)
			Spacer()
		}
	}
	
	private var pageTwo: some View {
		VStack {
			VStack(alignment: .leading, spacing: 8) {
				Text("1. Bypass of matrix \"snake\" (bustrofedion)")
					.font(.headline)
				VStack(alignment: .leading, spacing: 4) {
					Text("An array of elements of the matrix is created, bypassed by zmaihy:")
					Text("→ Even lines: from left to right")
					Text("← Odd lines: right to left")
					Text("Works for matrices of any size (even and odd).")
				}
			}
			.padding()
			.background(
				RoundedRectangle(cornerRadius: 16)
					.fill(Color.mm_background_primary)
					.overlay(
						RoundedRectangle(cornerRadius: 16)
							.stroke(Color.mm_divider_opaque, lineWidth: 2)
					)
			)
			Spacer()
		}
	}
	
	private var pageThree: some View {
		VStack {
			VStack(alignment: .leading, spacing: 8) {
				Text("2. Accuracy of inversions")
					.font(.headline)
				VStack(alignment: .leading, spacing: 4) {
					Text("Horizontal and vertical movements of empty cell (0) do not affect the overall straightness of inversions.")
					Text("Rearranging two non-zero cells changes the parity of the inversion.")
					Text("This is a key property to test the existence of a solution.")
				}
			}
			.padding()
			.background(
				RoundedRectangle(cornerRadius: 16)
					.fill(Color.mm_background_primary)
					.overlay(
						RoundedRectangle(cornerRadius: 16)
							.stroke(Color.mm_divider_opaque, lineWidth: 2)
					)
			)
			Spacer()
		}
		
	}
	
	private var pageFour: some View {
		VStack {
			VStack(alignment: .leading, spacing: 8) {
				Text("3. Solution verification")
					.font(.headline)
				VStack(alignment: .leading, spacing: 4) {
					Text("• Calculate the straightness of current state inversions")
					Text("• Calculate the precision of target state inversions")
					Text("• Compare:")
					Text("  - ✅ Pairs match → solution exists")
					Text("  - ❌ Equalities different → solution impossible")
				}
			}
			.padding()
			.background(
				RoundedRectangle(cornerRadius: 16)
					.fill(Color.mm_background_primary)
					.overlay(
						RoundedRectangle(cornerRadius: 16)
							.stroke(Color.mm_divider_opaque, lineWidth: 2)
					)
			)
			Spacer()
		}
	}
}
	

#Preview {
	InversionView(checker: MockChecker(), matrixWorker: MockMatrixWorker())
}
