//
//  LightsWorker.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 29.12.2024.
//

import SceneKit
import Foundation

/// Протокол описывающий взаимодествия с источниками света
protocol _LightsWorker {
	func setupLights(center: SCNVector3, radius: Float, rootNode: SCNNode)
}

final class LightsWorker: _LightsWorker {
	
	private let rotationWorker: _RotationWorker
	private let settingsLightStorage: _SettingsLightStorage
	
	/// Создание источника в виде конуса без точки свечения
	private func createOmniLightNode() -> SCNNode {
		let omniLight = SCNLight()
		omniLight.type = .omni
		omniLight.color = UIColor.white
		omniLight.intensity = 1000
		
		let sphere = SCNSphere(radius: CGFloat.random(in: 1...3))
		let sphereMaterial = SCNMaterial()
		sphereMaterial.diffuse.contents = UIColor.white
		sphereMaterial.emission.contents = UIColor.white
		sphere.materials = [sphereMaterial]
		
		let omniNode = SCNNode()
		omniNode.geometry = sphere
		omniNode.light = omniLight

		return omniNode
	}
	
	/// Создание источника в виде конуса без точки свечения
	private func createSpotLightNode() -> SCNNode {
		let spotLight = SCNLight()
		spotLight.type = .spot
		spotLight.color = UIColor.white
		spotLight.intensity = 1000
		spotLight.spotInnerAngle = 30
		spotLight.spotOuterAngle = 90
		
		let spotLightNode = SCNNode()
		spotLightNode.light = spotLight
		return spotLightNode
	}
	
	/// Создание источника в виде направленного источника света (как солнце)
	private func createdirectionalLightNode() -> SCNNode {
		let directionalLight = SCNLight()
		directionalLight.type = .directional
		directionalLight.color = UIColor.white
		directionalLight.intensity = 1000
		
		let directionalLightNode = SCNNode()
		directionalLightNode.light = directionalLight
		return directionalLightNode
	}
	
	/// Создание всенапраленного источника света
	private func createAmbientLightNode() -> SCNNode {
		let ambientLightNode = SCNNode()
		ambientLightNode.light = SCNLight()
		ambientLightNode.light?.type = .ambient
		ambientLightNode.light?.color = UIColor.white.cgColor
		return ambientLightNode
	}
	
	init(rotationWorker: _RotationWorker, settingsLightStorage: _SettingsLightStorage) {
		self.rotationWorker = rotationWorker
		self.settingsLightStorage = settingsLightStorage
	}
	
	func setupLights(center: SCNVector3, radius: Float, rootNode: SCNNode) {

		let delta: Float = 3
		for i in 1...self.settingsLightStorage.countLights {
			let lightNode: SCNNode
			switch self.settingsLightStorage.lightType {
			case .omni:
				lightNode = createOmniLightNode()
			case .spot:
				lightNode = createSpotLightNode()
			case .ambient:
				lightNode = createAmbientLightNode()
			case .directional:
				lightNode = createdirectionalLightNode()
			default:
				continue
			}
			if self.settingsLightStorage.isMotionEnabled {
				self.rotationWorker.createRotation(
					node: lightNode,
					rootNode: rootNode,
					centerOrbit: center
				)
			} else {
				rootNode.addChildNode(lightNode)
			}
			lightNode.castsShadow = self.settingsLightStorage.isShadowEnabled
			setPositionToRadiusMatrix(node: lightNode, radius: radius + delta * Float(i))
		}
	}
	
	/// Устанавливает позицию Node на радиусе сферы описаной, около матрицы
	/// - node: устанавливаемый узел
	/// - radius: радиус сферы на которой нужно назместить node
	private func setPositionToRadiusMatrix(node: SCNNode, radius: Float) {
		// Генерация случайных углов
		let theta = Float.random(in: 0...2 * Float.pi) // Азимутальный угол (0 до 2π)
		let phi = acos(2 * Float.random(in: 0...1) - 1) // Полярный угол (0 до π)
		
		// Перевод сферических координат в декартовы
		let x = radius * sin(phi) * cos(theta)
		let y = radius * sin(phi) * sin(theta)
		let z = radius * cos(phi)
		node.position = SCNVector3(x: x, y: y, z: z)
	}
}

final class MockLightsWorker: _LightsWorker {
	func setupLights(center: SCNVector3, radius: Float, rootNode: SCNNode) {
		debugPrint(#function)
	}
}
