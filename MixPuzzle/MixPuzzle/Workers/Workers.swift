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
	var imageWorker: _ImageWorker { get }
	var matrixWorker: _MatrixWorker { get }
	var asteroidWorker: _AsteroidsWorker { get }
	var materialsWorker: _MaterialsWorker { get }
}


final class Workers: _Workers {
	var keeper: _Keeper
	var gameWorker: _GameWorker
	var cubeWorker: _CubeWorker
	var imageWorker: _ImageWorker
	var matrixWorker: _MatrixWorker
	var asteroidWorker: _AsteroidsWorker
	var materialsWorker: _MaterialsWorker
	
	init(keeper: _Keeper, gameWorker: _GameWorker, cubeWorker: _CubeWorker, imageWorker: _ImageWorker, matrixWorker: _MatrixWorker, asteroidWorker: _AsteroidsWorker, materialsWorker: _MaterialsWorker) {
		self.keeper = keeper
		self.gameWorker = gameWorker
		self.cubeWorker = cubeWorker
		self.imageWorker = imageWorker
		self.matrixWorker = matrixWorker
		self.asteroidWorker = asteroidWorker
		self.materialsWorker = materialsWorker
	}
	
}

final class MockWorkers: _Workers {
	var keeper: _Keeper = MockFileWorker()
	
	var gameWorker: _GameWorker = MockGameWorker()
	
	lazy var cubeWorker: _CubeWorker = CubeWorker(imageWorker: self.imageWorker, materialsWorker: self.materialsWorker)
	
	var matrixWorker: _MatrixWorker = MockMatrixWorker()
	
	var imageWorker: _ImageWorker = ImageWorker()
	
	var asteroidWorker: _AsteroidsWorker = MockAsteroidsWorker()
	
	var materialsWorker: _MaterialsWorker = MaterialsWorker()
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
	
	func isSquereMatrix(matrix: [[MatrixElement]]) -> Bool {
		return true
	}
	
	func createMatrixRandom(size: Int) -> Matrix {
		[[]]
	}
	
	func creationMatrix(text: String) throws -> Matrix {
		[[]]
	}
	
	func fillBoardInSpiral(matrix: inout Matrix) {
		
	}
}
