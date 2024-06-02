//
//  Squeres.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 02.06.2024.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
	@State private var animate = false
	let size: CGFloat = 50
	let duration: Double = 1.0

	var body: some View {
		GeometryReader { geometry in
			ZStack {
				Color.white
					.edgesIgnoringSafeArea(.all)

				ForEach(0..<3) { index in
					Rectangle()
						.fill(Color.blue)
						.frame(width: size, height: size)
						.offset(x: self.getXOffset(index: index, geo: geometry),
								y: self.getYOffset(index: index, geo: geometry))
				}
			}
			.frame(width: geometry.size.width, height: geometry.size.height)
			.onAppear {
				withAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: false)) {
					self.animate.toggle()
				}
			}
		}
	}

	private func getXOffset(index: Int, geo: GeometryProxy) -> CGFloat {
		let midX: CGFloat = geo.size.width / 64
		//let midX: CGFloat = 10
		let offset: CGFloat = 100
		if animate {
			switch index {
			case 0: return midX + offset
			case 1: return midX + offset
			case 2: return midX - offset
			default: return midX
			}
		} else {
			switch index {
			case 0: return midX + offset
			case 1: return midX + offset
			case 2: return midX + offset
			default: return midX
			}
		}
	}

	private func getYOffset(index: Int, geo: GeometryProxy) -> CGFloat {
		let midY = geo.size.height / 64
		let offset: CGFloat = 100
		if animate {
			switch index {
			case 0: return midY
			case 1: return midY - offset
			case 2: return midY
			default: return midY
			}
		} else {
			switch index {
			case 0: return midY - offset
			case 1: return midY
			case 2: return midY + offset
			default: return midY
			}
		}
	}
}
//
//struct ContentView: View {
//	@State private var positions: [CGPoint] = [
//		CGPoint(x: 50, y: 50),
//		CGPoint(x: 50, y: 150),
//		CGPoint(x: 150, y: 150),
//		CGPoint(x: 150, y: 50),
//	]
//	
//	@State private var currentIndex = 0
//
//	var body: some View {
//		ZStack {
//			ForEach(0..<3) { index in
//				Rectangle()
//					.fill(Color.blue)
//					.frame(width: 50, height: 50)
//					.position(self.positions[index])
//			}
//		}
//		.onAppear {
//			Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//				withAnimation(.easeInOut(duration: 1)) {
//					self.moveSquares()
//				}
//			}
//		}
//		.frame(maxWidth: .infinity, maxHeight: .infinity)
//	}
//	
//	func moveSquares() {
//		let indexTwo = (currentIndex + 1) % positions.count
//		let indexThree = (currentIndex + 2) % positions.count
//		positions.swapAt(indexThree, indexTwo)
//		positions.swapAt(currentIndex, indexTwo)
//		currentIndex = indexThree
//	}
//}

#Preview {
	ContentView()
}
