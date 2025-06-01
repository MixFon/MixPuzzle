//
//  Workers.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 07.05.2024.
//

import MFPuzzle
import Foundation

protocol _Workers {
	var keeper: _Keeper { get }
	var gameWorker: _GameWorker { get }
	var cubeWorker: _CubeWorker { get }
	var transporter: any _Transporter { get }
	var imageWorker: _ImageWorker { get }
	var lightsWorker: _LightsWorker { get }
	var matrixWorker: _MatrixWorker { get }
	var rotationWorker: _RotationWorker { get }
	var textNodeWorker: _TextNodeWorker { get }
	var asteroidWorker: _AsteroidsWorker { get }
	var materialsWorker: _MaterialsWorker { get }
}


final class Workers: _Workers {
	let keeper: _Keeper
	let gameWorker: _GameWorker
	let cubeWorker: _CubeWorker
	let transporter: any _Transporter
	let imageWorker: _ImageWorker
	let lightsWorker: _LightsWorker
	let matrixWorker: _MatrixWorker
	let rotationWorker: _RotationWorker
	let textNodeWorker: _TextNodeWorker
	let asteroidWorker: _AsteroidsWorker
	let materialsWorker: _MaterialsWorker
	
	init(keeper: _Keeper, gameWorker: _GameWorker, cubeWorker: _CubeWorker, transporter: any _Transporter, imageWorker: _ImageWorker, lightsWorker: _LightsWorker, matrixWorker: _MatrixWorker, rotationWorker: _RotationWorker, textNodeWorker: _TextNodeWorker, asteroidWorker: _AsteroidsWorker, materialsWorker: _MaterialsWorker) {
		self.keeper = keeper
		self.gameWorker = gameWorker
		self.cubeWorker = cubeWorker
		self.transporter = transporter
		self.imageWorker = imageWorker
		self.lightsWorker = lightsWorker
		self.matrixWorker = matrixWorker
		self.rotationWorker = rotationWorker
		self.textNodeWorker = textNodeWorker
		self.asteroidWorker = asteroidWorker
		self.materialsWorker = materialsWorker
	}
}


final class MockWorkers: _Workers {
	let keeper: any _Keeper
	let gameWorker: any _GameWorker
	let transporter: any _Transporter
	let textNodeWorker: any _TextNodeWorker
	let rotationWorker: any _RotationWorker
	let cubeWorker: any _CubeWorker
	let matrixWorker: any _MatrixWorker
	let imageWorker: any _ImageWorker
	let lightsWorker: any _LightsWorker
	let asteroidWorker: any _AsteroidsWorker
	let materialsWorker: any _MaterialsWorker

	@MainActor
	init() {
		self.keeper = MockFileWorker()
		self.gameWorker = MockGameWorker()
		self.transporter = MockTransporter()
		self.textNodeWorker = MockTextNodeWorker()
		self.rotationWorker = MockRotationWorker()
		self.matrixWorker = MockMatrixWorker()
		self.lightsWorker = MockLightsWorker()
		self.asteroidWorker = MockAsteroidsWorker()

		// Создание актор-зависимых объектов — через MainActor.run
		let imageWorker = ImageWorker()
		let materialsWorker = MaterialsWorker()
		self.imageWorker = imageWorker
		self.materialsWorker = materialsWorker
		self.cubeWorker = CubeWorker(imageWorker: imageWorker, materialsWorker: materialsWorker)
	}
}


final class MockMatrixWorker: _MatrixWorker {
	func createMatrixSolution(size: Int, solution: Solution) -> Matrix {
		Matrix()
	}
	
	func createMatrixBoustrophedon(size: Int) -> Matrix {
		Matrix()
	}
	
	func createMatrixClassic(size: Int) -> Matrix {
		Matrix()
	}
	
	func createMatrixSnail(size: Int) -> Matrix {
		[[]]
	}
	
	func changesParityInvariant(matrix: inout Matrix) {
		
	}
	
	func createMatrixRandom(size: Int) -> Matrix {
		if size == 3 {
			[[1, 2, 3],
			 [9, 0, 4],
			 [7, 6, 5]]
		} else {
			[[ 1,  2,  3,  4],
			 [12, 13, 14,  5],
			 [11, 10, 15,  6],
			 [ 0,  9,  8,  7]]
		}
	}
	
	func creationMatrix(text: String) throws -> Matrix {
		[[]]
	}
	
	func fillBoardInSpiral(matrix: inout Matrix) {
		
	}
}

final class MockTransporter: _Transporter {
	typealias Cargo = Int
	func createDirections(from current: [[Int]], to solution: [[Int]]) -> [Int : [MFPuzzle.Direction]] {
		[:]
	}
	
	func createShortestPath(from current: [[Int]], to solution: [[Int]]) -> [Int : [MFPuzzle.Direction]] {
		[:]
	}
}
