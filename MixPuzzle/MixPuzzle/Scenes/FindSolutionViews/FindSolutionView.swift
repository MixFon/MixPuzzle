//
//  FindSolutionView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 24.05.2024.
//

import SwiftUI

final class FindSolutionRouter: ObservableObject {
	@Published var toScan = false
	@Published var toPhoto = false
	@Published var toManual = false
	
}

struct FindSolutionView: View {
	let dependency: _Dependency
	
	@ObservedObject private var router = FindSolutionRouter()
	
    var body: some View {
		VStack {
			NavigationBar(title: "Find a solution")
			.padding()
			VStack {
				FindSolutionButton(title: "Manual", subtitle: "You will need to set and fill in the matrix yourself.", systemIcon: "hand.point.up.braille") {
					self.router.toManual = true
				}
				FindSolutionButton(title: "Photo", subtitle: "You will need to select a photo with a puzzle for recognition.", systemIcon: "photo.on.rectangle") {
					self.router.toPhoto = true
				}
				FindSolutionButton(title: "Scan", subtitle: "You will need to scan the puzzle with a camera.", systemIcon: "doc.viewfinder") {
					self.router.toScan = true
				}
			}
			.padding()
			Spacer()
		}
		.background(Color.mm_background_secondary)
    }
}

struct FindSolutionButton: View {
	let title: String
	let subtitle: String
	let systemIcon: String
	var action: ()->()
	
	var body: some View {
		Button(action: self.action) {
			FindSolutionCellView(title: self.title, subtitle: self.subtitle, systemIcon: self.systemIcon)
		}
		.background(Color.mm_background_tertiary)
		.foregroundStyle(Color.mm_tint_icons)
		.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
		.buttonStyle(.plain)
	}
}

struct FindSolutionCellView: View {
	let title: String
	let subtitle: String
	let systemIcon: String
	
	var body: some View {
		HStack {
			Image(systemName: self.systemIcon)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 48, height: 48, alignment: .center)
				.padding()
			VStack(alignment: .leading) {
				Text(self.title)
					.font(.title)
					.multilineTextAlignment(.leading)
					.foregroundStyle(Color.mm_text_primary)
				Text(self.subtitle)
					.font(.subheadline)
					.multilineTextAlignment(.leading)
					.foregroundStyle(Color.mm_text_secondary)
			}
			.padding(.vertical)
			Spacer()
		}
	}
}


#Preview {
	let dependency = MockDependency()
    return FindSolutionView(dependency: dependency)
}

