//
//  CubeWorker.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 14.04.2024.
//

import SceneKit
import Foundation

/// Отвечает за создание одного кубика
protocol _CubeWorker {
	/// Возвращает кубик с текстом-картинкой
	/// - textImage - текст который будет в круге
	/// - lengthEdge - длина ребра кубика
	func getCube(textImage: String, lengthEdge: CGFloat) -> SCNNode
	
	/// Изменение радиуса на гране куба
	func changeRadiusFor(cube: SCNNode, radius: Double)
}

final class CubeWorker: _CubeWorker {
	
	/// Создание изображения по указанным параметрам
	private let imageWorker: _ImageWorker
	
	init(imageWorker: _ImageWorker) {
		self.imageWorker = imageWorker
	}
	
	func getCube(textImage: String, lengthEdge: CGFloat) -> SCNNode {
		let boxNode = SCNNode()
		boxNode.geometry = SCNBox(width: lengthEdge, height: lengthEdge, length: lengthEdge, chamferRadius: 1)
		
		//let im = UIImage(systemName: "\(box.number).circle.fill")
		let im = self.imageWorker.imageWith(textImage: textImage)
		
		let material = SCNMaterial()
		// Является базой для поверхности
		material.diffuse.contents = im
		
		// Отвечат за металический отблеск
		material.specular.contents = UIImage(named: "bubble", in: nil, with: nil)
		
		// Отвечает за зеркальный отблеск, в отражени будут обекты, переданные в contents
		//material.reflective.contents = UIImage(named: "bubble", in: nil, with: nil)
		
		// Используется для затемнения или тонирования. Можно использовать как теневую карту
		//material.multiply.contents = im
		
		// Можно имитировать облака
		//material.transparent.contents = UIImage(named: "bubble", in: nil, with: nil)
		//material.ambient.contents =
		
		boxNode.geometry?.firstMaterial = material
		return boxNode
	}
	
	func changeRadiusFor(cube: SCNNode, radius: Double) {
		let im = self.imageWorker.imageWith(textImage: "12", radius: radius)
		cube.geometry?.firstMaterial
	}
}