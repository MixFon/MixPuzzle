//
//  StarsWorker.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 06.04.2024.
//

import SceneKit
import Foundation

protocol _AsteroidsWorker {
	func createAsteroids() -> [SCNNode]
	func deleteAsteroids()
    func setAnimationRotationTo(node: SCNNode)
}

final class AsteroidsWorker: _AsteroidsWorker {
    
    private let materialsWorker: _MaterialsWorker
    private let asteroidsStorage: _SettingsAsteroidsStorage
	private var asteroids: [SCNNode]?
	
	private var radiusSphere: Double {
		self.asteroidsStorage.radiusSphere
	}
	
	private var countAsteroids: Int {
		Int(self.asteroidsStorage.asteroidsCount)
	}
    
    init(materialsWorker: _MaterialsWorker, asteroidsStorage: _SettingsAsteroidsStorage) {
        self.materialsWorker = materialsWorker
        self.asteroidsStorage = asteroidsStorage
    }
	
	func createAsteroids() -> [SCNNode] {
		let asteroids = (0...self.countAsteroids).map( { _ in createAsteroid() } )
		self.asteroids = asteroids
		return asteroids
	}
	
	func deleteAsteroids() {
		self.asteroids?.forEach( { $0.removeFromParentNode() } )
	}
	
	private func createAsteroid() -> SCNNode {
        let rocks = [
            "coral_fort_wall",
            "shfsaida",
            "sbbihkp",
            "rock_face_03",
        ]
        let configurationTexture = ConfigurationTexture(texture: rocks.randomElement() ?? "")
        let radiusSphere = CGFloat.random(in: 0.1...0.4)
        let sphereGeometry = SCNSphere(radius: radiusSphere) // Радиус сферы
        
        let sphereMaterial = SCNMaterial() // Создание материала для сферы
        
        self.materialsWorker.configureMaterialDiffuse(material: sphereMaterial, texture: configurationTexture)
        sphereGeometry.firstMaterial = sphereMaterial // Применение материала к сфере
        
		let sphereNode = SCNNode(geometry: sphereGeometry)
		let position = calculatePositionOnSphere(radius: self.radiusSphere)
        setAnimationRotationTo(node: sphereNode)
        sphereNode.position = position
		return sphereNode
	}
    
    func setAnimationRotationTo(node: SCNNode) {
        // Анимация вращения сферы вокруг узла
        let a = Double.random(in: 1...3)
        let b = Double.random(in: 1...3)
        let c = Double.random(in: 1...3)
        let duration = Double.random(in: 40...50)
        let rotation = SCNAction.rotateBy(x: CGFloat(a * Double.pi), y: CGFloat(b * Double.pi), z: CGFloat(c * Double.pi), duration: duration)
        let repeatForever = SCNAction.repeatForever(rotation)
        node.runAction(repeatForever)
    }
	
	/// Возвращает позицию на сфуре радиусом
	private func calculatePositionOnSphere(radius: CGFloat) -> SCNVector3 {
		// teta - полярное расстояние измеряется от 0 до 180
		// lambda -долгота измеряется от 0 до 360
		let teta = CGFloat.random(in: 0...180)
		let lambda = CGFloat.random(in: 0...360)
		
		let x = radius * sin(degreeToRadian(degree: teta)) * cos(degreeToRadian(degree: lambda))
		let y = radius * sin(degreeToRadian(degree: teta)) * sin(degreeToRadian(degree: lambda))
		let z = radius * cos(degreeToRadian(degree: teta))
        return SCNVector3(x: Float(x), y: Float(y), z: Float(z))
	}
	
	private func degreeToRadian(degree: CGFloat) -> CGFloat {
		return CGFloat.pi / 180.0 * degree
	}
}

final class MockAsteroidsWorker: _AsteroidsWorker {
	func deleteAsteroids() {
	}
	
	func createAsteroids() -> [SCNNode] {
		return []
	}
	
	func setAnimationRotationTo(node: SCNNode) {
		
	}
}
