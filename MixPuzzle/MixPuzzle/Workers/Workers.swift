//
//  Workers.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 07.05.2024.
//

import MFPuzzle
import Foundation

protocol _Workers {
	var fileWorker: _FileWorker { get }
	var gameWorker: _GameWorker { get }
	var cubeWorker: _CubeWorker { get }
	var imageWorker: _ImageWorker { get }
	var matrixWorker: _MatrixWorker { get }
	var asteroidWorker: _AsteroidsWorker { get }
	var materialsWorker: _MaterialsWorker { get }
}


final class Workers: _Workers {
	var fileWorker: _FileWorker
	var gameWorker: _GameWorker
	var cubeWorker: _CubeWorker
	var imageWorker: _ImageWorker
	var matrixWorker: _MatrixWorker
	var asteroidWorker: _AsteroidsWorker
	var materialsWorker: _MaterialsWorker
	
	init(fileWorker: _FileWorker, gameWorker: _GameWorker, cubeWorker: _CubeWorker, imageWorker: _ImageWorker, matrixWorker: _MatrixWorker, asteroidWorker: _AsteroidsWorker, materialsWorker: _MaterialsWorker) {
		self.fileWorker = fileWorker
		self.gameWorker = gameWorker
		self.cubeWorker = cubeWorker
		self.imageWorker = imageWorker
		self.matrixWorker = matrixWorker
		self.asteroidWorker = asteroidWorker
		self.materialsWorker = materialsWorker
	}
	
}

final class MockWorkers: _Workers {
	var fileWorker: _FileWorker = MockFileWorker()
	
	var gameWorker: _GameWorker = MockGameWorker()
	
	var cubeWorker: _CubeWorker = MockCubeWorker()
	
	var matrixWorker: _MatrixWorker = MockMatrixWorker()
	
	var imageWorker: _ImageWorker = MockImageWorker()
	
	var asteroidWorker: _AsteroidsWorker = MockAsteroidsWorker()
	
	var materialsWorker: _MaterialsWorker = MockMaterialsWorker()
}

final class MockMatrixWorker: _MatrixWorker {
	func createMatrixClassic(size: Int) -> MFPuzzle.Matrix {
		Matrix()
	}
	
	func createMatrixSnail(size: Int) -> Matrix {
		[[]]
	}
	
	func createMatrixSnake(size: Int) -> Matrix {
		Matrix()
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
