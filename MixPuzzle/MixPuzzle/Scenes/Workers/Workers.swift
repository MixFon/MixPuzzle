//
//  Workers.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 07.05.2024.
//

import Foundation

protocol _Workers {
	var fileWorker: _FileWorker { get }
	var gameWorker: _GameWorker { get }
	var cubeWorker: _CubeWorker { get }
	var imageWorker: _ImageWorker { get }
	var asteroidWorker: _AsteroidsWorker { get }
	var materialsWorker: _MaterialsWorker { get }
}


final class Workers: _Workers {
	var fileWorker: _FileWorker
	var gameWorker: _GameWorker
	var cubeWorker: _CubeWorker
	var imageWorker: _ImageWorker
	var asteroidWorker: _AsteroidsWorker
	var materialsWorker: _MaterialsWorker
	
	init(fileWorker: _FileWorker, gameWorker: _GameWorker, cubeWorker: _CubeWorker, imageWorker: _ImageWorker, asteroidWorker: _AsteroidsWorker, materialsWorker: _MaterialsWorker) {
		self.fileWorker = fileWorker
		self.gameWorker = gameWorker
		self.cubeWorker = cubeWorker
		self.imageWorker = imageWorker
		self.asteroidWorker = asteroidWorker
		self.materialsWorker = materialsWorker
	}
	
}

final class MockWorkers: _Workers {
	var fileWorker: _FileWorker = MockFileWorker()
	
	var gameWorker: _GameWorker = MockGameWorker()
	
	var cubeWorker: _CubeWorker = MockCubeWorker()
	
	var imageWorker: _ImageWorker = MockImageWorker()
	
	var asteroidWorker: _AsteroidsWorker = MockAsteroidsWorker()
	
	var materialsWorker: _MaterialsWorker = MockMaterialsWorker()
	
	
}
