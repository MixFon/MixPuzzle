//
//  CubeButtonView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 19.04.2024.
//
import SwiftUI

struct CubeShape: Shape {
	
	func path(in rect: CGRect) -> Path {
		Path { path in
			path.move(to: CGPoint(x: rect.minX, y: rect.minY))
			path.addLine(to: CGPoint(x: rect.maxX - rect.width / 4, y: rect.minY))
			path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height / 4))
			path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
			path.addLine(to: CGPoint(x: rect.minX + rect.width / 4, y: rect.maxY))
			path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - rect.maxY / 4))
			path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
			path.addLine(to: CGPoint(x: rect.minX + rect.width / 4, y: rect.minY + rect.height / 4))
			path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height / 4))
			path.addLine(to: CGPoint(x: rect.minX + rect.width / 4, y: rect.minY + rect.height / 4))
			path.addLine(to: CGPoint(x: rect.minX + rect.width / 4, y: rect.maxY))
		}
	}
	
}

struct IsometricCubeButton: View {
	let color: Color
	var body: some View {
		Button {
			
		} label: {
			Text("D")
				.font(.system(.title, design: .rounded))
				.bold()
				.foregroundColor(.white)
				.frame(width: 100, height: 100)
				.background(CubeShape().stroke(Color.black, lineWidth: 3))
				.background(CubeShape().fill(color))
		}
	}
}

#Preview {
	VStack {
		IsometricCubeButton(color: .red)
	}
}

