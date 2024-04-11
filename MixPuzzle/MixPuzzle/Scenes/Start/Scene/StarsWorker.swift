//
//  StarsWorker.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 06.04.2024.
//

import SceneKit
import Foundation

protocol _StarsWorker {
	func createStart(centre: SCNVector3) -> [SCNNode]
}

final class StarsWorker: _StarsWorker {
	
	let countStars = 200
	let radiusSphere: Double = 20
	
	func createStart(centre: SCNVector3) -> [SCNNode] {
		let stars = (0...self.countStars).map( { _ in createStar(centre: centre) } )
		return stars
	}
	
	private func createStar(centre: SCNVector3) -> SCNNode {
		let radiusSphere = CGFloat.random(in: 0.1...0.3)
		let sphereGeometry = SCNSphere(radius: radiusSphere) // Радиус сферы
		
		let sphereMaterial = SCNMaterial() // Создание материала для сферы
		sphereMaterial.emission.contents = UIColor.white // Задание цвета свечения сферы
		sphereGeometry.materials = [sphereMaterial] // Применение материала к сфере
		
		let sphereNode = SCNNode(geometry: sphereGeometry)
		let position = calculatePositionOnSphere(radius: self.radiusSphere, centre: centre)
		sphereNode.position = position
		return sphereNode
	}
	
	/// Возвращает позицию на сфуре радиусом
	private func calculatePositionOnSphere(radius: CGFloat, centre: SCNVector3) -> SCNVector3 {
		// teta - полярное расстояние измеряется от 0 до 180
		// lambda -долгота измеряется от 0 до 360
		let teta = CGFloat.random(in: 0...180)
		let lambda = CGFloat.random(in: 0...360)
		
		let x = radius * sin(degreeToRadian(degree: teta)) * cos(degreeToRadian(degree: lambda))
		let y = radius * sin(degreeToRadian(degree: teta)) * sin(degreeToRadian(degree: lambda))
		let z = radius * cos(degreeToRadian(degree: teta))
		return SCNVector3(x: Float(x) + centre.x, y: Float(y) + centre.y, z: Float(z) + centre.z)
	}
	
	private func degreeToRadian(degree: CGFloat) -> CGFloat {
		return CGFloat.pi / 180.0 * degree
	}
}
