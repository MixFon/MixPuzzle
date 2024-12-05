//
//  LongPress.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 05.12.2024.
//

import SwiftUI

struct LongPressGestureView: View {
	@GestureState private var isDetectingLongPress = false
	@State private var completedLongPress = false
	
	
	var longPress: some Gesture {
		LongPressGesture(minimumDuration: 1)
			.updating($isDetectingLongPress) { currentState, gestureState, transaction in
				gestureState = currentState
				transaction.animation = Animation.easeIn(duration: 1.0)
			}
			.onChanged { value in
				print(value)
			}
			.onEnded { finished in
				self.completedLongPress.toggle()
			}
	}
	
	
	var body: some View {
		Circle()
			.fill(self.isDetectingLongPress ? Color.red : (self.completedLongPress ? Color.green : Color.blue))
			.frame(width: 100, height: 100, alignment: .center)
			//.gesture(longPress)
			.onLongPressGesture(minimumDuration: 1) {
				print("Long pressed!")
			} onPressingChanged: { inProgress in
				print("In progress: \(inProgress)!")
			}
	}
}
#Preview {
	LongPressGestureView()
}
