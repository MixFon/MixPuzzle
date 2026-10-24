//
//  StarsWorker.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 06.04.2024.
//

import SceneKit
import Foundation

@MainActor
protocol _AsteroidsWorker {
	func createAsteroids(rootNode: SCNNode, centerOrbit: SCNVector3)
	func deleteAsteroids()
	/// Приводит астероиды к заданному количеству и радиусу сферы, не пересоздавая все.
	/// Лишние удаляются, недостающие добавляются, существующие сдвигаются на новый радиус. Для живого превью настроек
	func updateAsteroids(count: Int, radius: Double, rootNode: SCNNode, centerOrbit: SCNVector3)
}

final class AsteroidsWorker: _AsteroidsWorker {
    
	private var asteroids: [Asteroid]?
	private let rotationWorker: _RotationWorker
    private let materialsWorker: _MaterialsWorker
    private let asteroidsStorage: _SettingsAsteroidsStorage
	
	private struct Asteroid {
		var node: SCNNode
		var orbitNode: SCNNode
	}
	
	private var radiusSphere: Double {
		self.asteroidsStorage.radiusSphere
	}
	
	private var countAsteroids: Int {
		Int(self.asteroidsStorage.asteroidsCount)
	}
    
    init(rotationWorker: _RotationWorker, materialsWorker: _MaterialsWorker, asteroidsStorage: _SettingsAsteroidsStorage) {
		self.rotationWorker = rotationWorker
        self.materialsWorker = materialsWorker
        self.asteroidsStorage = asteroidsStorage
    }
	
	func createAsteroids(rootNode: SCNNode, centerOrbit: SCNVector3) {
		var asteroids: [Asteroid] = []
		for _ in (0...self.countAsteroids) {
			let node = createAsteroid(radius: self.radiusSphere)
			let orbitNode = self.rotationWorker.createRotation(node: node, rootNode: rootNode, centerOrbit: centerOrbit)
			let asteroid = Asteroid(
				node: node,
				orbitNode: orbitNode
			)
			asteroids.append(asteroid)
		}
		self.asteroids = asteroids
	}
	
	func deleteAsteroids() {
		self.asteroids?.forEach{ asteroid in
			asteroid.node.removeFromParentNode()
			asteroid.orbitNode.removeFromParentNode()
		}
		self.asteroids = nil
	}
	
	func updateAsteroids(count: Int, radius: Double, rootNode: SCNNode, centerOrbit: SCNVector3) {
		var asteroids = self.asteroids ?? []
		let count = max(count, 0)
		if asteroids.count > count {
			asteroids[count...].forEach { asteroid in
				asteroid.node.removeFromParentNode()
				asteroid.orbitNode.removeFromParentNode()
			}
			asteroids.removeLast(asteroids.count - count)
		}
		// Существующие астероиды переносим на сферу нового радиуса, сохраняя направление
		SCNTransaction.begin()
		SCNTransaction.animationDuration = 0.2
		for asteroid in asteroids {
			let position = asteroid.node.position
			let length = sqrt(position.x * position.x + position.y * position.y + position.z * position.z)
			guard length > 0 else { continue }
			let k = Float(radius) / length
			asteroid.node.position = SCNVector3(x: position.x * k, y: position.y * k, z: position.z * k)
		}
		SCNTransaction.commit()
		while asteroids.count < count {
			let node = createAsteroid(radius: radius)
			let orbitNode = self.rotationWorker.createRotation(node: node, rootNode: rootNode, centerOrbit: centerOrbit)
			asteroids.append(Asteroid(node: node, orbitNode: orbitNode))
		}
		self.asteroids = asteroids
	}
	
	private func createAsteroid(radius: CGFloat) -> SCNNode {
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
		let position = calculatePositionOnSphere(radius: radius)
		self.rotationWorker.setAnimationRotationTo(node: sphereNode)
        sphereNode.position = position
		return sphereNode
	}
	
	/// Возвращает позицию на сфере радиусом
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
	
	func createAsteroids(rootNode: SCNNode, centerOrbit: SCNVector3) {
		
	}
	
	func setAnimationRotationTo(node: SCNNode) {
		
	}
	
	func updateAsteroids(count: Int, radius: Double, rootNode: SCNNode, centerOrbit: SCNVector3) {
		
	}
}
