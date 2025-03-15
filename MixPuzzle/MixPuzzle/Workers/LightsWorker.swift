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
		spotLight.spotInnerAngle = 45
		spotLight.spotOuterAngle = 60
		
		let spotLightNode = SCNNode()
		spotLightNode.light = spotLight
		return spotLightNode
	}
	
	/// Создание источника в виде направленного источника света (как солнце)
	private func createDirectionalLightNode() -> SCNNode {
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
		switch self.settingsLightStorage.lightType {
		case .omni:
			configureOmniLight(center: center, radius: radius, rootNode: rootNode)
		case .spot:
			configureSpotLight(center: center, radius: radius, rootNode: rootNode)
		case .ambient:
			configureAmbientLight(center: center, radius: radius, rootNode: rootNode)
		case .directional:
			configareDirectionalLight(center: center, radius: radius, rootNode: rootNode)
		default:
			break
		}
	}
	
	/// Настройка освещения под Omni
	private func configureOmniLight(center: SCNVector3, radius: Float, rootNode: SCNNode) {
		let delta: Float = 3
		for i in 1...self.settingsLightStorage.countLights {
			let omniLight = createOmniLightNode()
			setRotarionIfNeeded(center: center, rootNode: rootNode, lightNode: omniLight)
			omniLight.light?.castsShadow = self.settingsLightStorage.isShadowEnabled
			setPositionToRadiusMatrix(node: omniLight, radius: radius + delta * Float(i))
		}
	}
	
	/// Настройка освещения под Spot
	private func configureSpotLight(center: SCNVector3, radius: Float, rootNode: SCNNode) {
		for _ in 1...self.settingsLightStorage.countLights {
			let spotLight = createSpotLightNode()
			setRotarionIfNeeded(center: center, rootNode: rootNode, lightNode: spotLight)
			spotLight.light?.castsShadow = self.settingsLightStorage.isShadowEnabled
			setPositionToRadiusMatrix(node: spotLight, radius: radius * 2)
			spotLight.look(at: center)
		}
	}
	
	/// Настройка освещения под Directional
	private func configareDirectionalLight(center: SCNVector3, radius: Float, rootNode: SCNNode) {
		let ambientLight = createDirectionalLightNode()
		setRotarionIfNeeded(center: center, rootNode: rootNode, lightNode: ambientLight)
		ambientLight.light?.castsShadow = self.settingsLightStorage.isShadowEnabled
	}
	
	/// Настройка освещения под Ambient
	private func configureAmbientLight(center: SCNVector3, radius: Float, rootNode: SCNNode) {
		let ambientLight = createAmbientLightNode()
		ambientLight.light?.castsShadow = self.settingsLightStorage.isShadowEnabled
		rootNode.addChildNode(ambientLight)
	}
	
	/// Установка вращения узла по флагу isMotionEnabled
	private func setRotarionIfNeeded(center: SCNVector3, rootNode: SCNNode, lightNode: SCNNode) {
		if self.settingsLightStorage.isMotionEnabled {
			self.rotationWorker.createRotation(
				node: lightNode,
				rootNode: rootNode,
				centerOrbit: center
			)
		} else {
			rootNode.addChildNode(lightNode)
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
