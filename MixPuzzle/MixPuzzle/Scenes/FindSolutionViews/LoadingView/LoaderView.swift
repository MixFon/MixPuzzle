import SwiftUI

struct MovingSquaresLoader: View {
	private let gridSize = 3
	private let squareSize: CGFloat = 40
	private let animationDuration: UInt64 = UInt64(0.3 * Double(NSEC_PER_SEC))
	@State private var emptyPosition = (1, 1)
	@State private var squares: [(Int, Int)] = [
		(0, 0), (0, 1), (0, 2),
		(1, 0),         (1, 2),
		(2, 0), (2, 1), (2, 2),
	]
	
	var body: some View {
		VStack {
			Grid()
				.frame(width: squareSize * CGFloat(gridSize), height: squareSize * CGFloat(gridSize))
		}
	}
	
	private func Grid() -> some View {
		ZStack {
			ForEach(0..<gridSize, id: \.self) { row in
				ForEach(0..<gridSize, id: \.self) { col in
					if squares.contains(where: { $0 == (row, col) }) {
						Rectangle()
							.fill(Color.blue)
							.frame(width: squareSize, height: squareSize)
							.clipShape(RoundedRectangle(cornerRadius: 10))
							.position(
								x: CGFloat(col) * squareSize + squareSize / 2,
								y: CGFloat(row) * squareSize + squareSize / 2
							)
					}
				}
			}
		}
		.onAppear {
			animateSquares()
		}
	}
	
	private func animateSquares() {
		Task {
			let moves: [(Int, Int)] = [(1, 0), (0, 1), (-1, 0), (-1, 0), (0, -1), (0, -1), (1, 0), (1, 0), (0, 1), (-1, 0), (-1, 0), (0, -1), (1, 0), (0, 1)]
			var index = 0
			while true {
				await MainActor.run {
					withAnimation( .interactiveSpring) {
						let move = moves[index]
						let newPos = (emptyPosition.0 + move.0, emptyPosition.1 + move.1)
						if let movingIndex = squares.firstIndex(where: { $0 == newPos }) {
							squares[movingIndex] = emptyPosition
							emptyPosition = newPos
						}
						index = (index + 1) % moves.count
					}
				}
				try? await Task.sleep(nanoseconds: self.animationDuration)
			}
		}
	}
}

struct MovingSquaresLoader_Previews: PreviewProvider {
	static var previews: some View {
		MovingSquaresLoader()
	}
}
