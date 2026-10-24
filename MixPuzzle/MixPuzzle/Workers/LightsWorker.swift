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
	/// Создает источники света по настройкам из хранилища
	func setupLights(center: SCNVector3, radius: Float, rootNode: SCNNode)
	/// Удаляет созданные этим воркером источники и создает новые по переданным настройкам. Для живого превью настроек
	func updateLights(configuration: LightsConfiguration, center: SCNVector3, radius: Float, rootNode: SCNNode)
}

/// Настройки освещения сцены
struct LightsConfiguration: Equatable {
	var lightType: LightType
	var countLights: Int
	var isMotionEnabled: Bool
	var isShadowEnabled: Bool
}

extension LightsConfiguration {
	init(storage: _SettingsLightStorage) {
		self.init(
			lightType: storage.lightType,
			countLights: storage.countLights,
			isMotionEnabled: storage.isMotionEnabled,
			isShadowEnabled: storage.isShadowEnabled
		)
	}
}

final class LightsWorker: _LightsWorker {
	
	private let rotationWorker: _RotationWorker
	private let settingsLightStorage: _SettingsLightStorage
	/// Верхние узлы созданных источников (сам источник или его орбита), чтобы их можно было удалить
	private var createdNodes: [SCNNode] = []
	
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
		let configuration = LightsConfiguration(storage: self.settingsLightStorage)
		self.createdNodes = createLights(configuration: configuration, center: center, radius: radius, rootNode: rootNode)
	}
	
	func updateLights(configuration: LightsConfiguration, center: SCNVector3, radius: Float, rootNode: SCNNode) {
		self.createdNodes.forEach { $0.removeFromParentNode() }
		self.createdNodes = createLights(configuration: configuration, center: center, radius: radius, rootNode: rootNode)
	}
	
	/// Создает источники и возвращает их верхние узлы
	private func createLights(configuration: LightsConfiguration, center: SCNVector3, radius: Float, rootNode: SCNNode) -> [SCNNode] {
		switch configuration.lightType {
		case .omni:
			return configureOmniLight(configuration: configuration, center: center, radius: radius, rootNode: rootNode)
		case .spot:
			return configureSpotLight(configuration: configuration, center: center, radius: radius, rootNode: rootNode)
		case .ambient:
			return configureAmbientLight(configuration: configuration, rootNode: rootNode)
		case .directional:
			return configareDirectionalLight(configuration: configuration, center: center, rootNode: rootNode)
		case .undefined:
			return []
		}
	}
	
	/// Настройка освещения под Omni
	private func configureOmniLight(configuration: LightsConfiguration, center: SCNVector3, radius: Float, rootNode: SCNNode) -> [SCNNode] {
		let delta: Float = 3
		var nodes: [SCNNode] = []
		for i in 1...max(configuration.countLights, 1) {
			let omniLight = createOmniLightNode()
			nodes.append(setRotarionIfNeeded(configuration: configuration, center: center, rootNode: rootNode, lightNode: omniLight))
			omniLight.light?.castsShadow = configuration.isShadowEnabled
			setPositionToRadiusMatrix(node: omniLight, radius: radius + delta * Float(i))
		}
		return nodes
	}
	
	/// Настройка освещения под Spot
	private func configureSpotLight(configuration: LightsConfiguration, center: SCNVector3, radius: Float, rootNode: SCNNode) -> [SCNNode] {
		var nodes: [SCNNode] = []
		for _ in 1...max(configuration.countLights, 1) {
			let spotLight = createSpotLightNode()
			nodes.append(setRotarionIfNeeded(configuration: configuration, center: center, rootNode: rootNode, lightNode: spotLight))
			spotLight.light?.castsShadow = configuration.isShadowEnabled
			setPositionToRadiusMatrix(node: spotLight, radius: radius * 2)
			spotLight.look(at: center)
		}
		return nodes
	}
	
	/// Настройка освещения под Directional
	private func configareDirectionalLight(configuration: LightsConfiguration, center: SCNVector3, rootNode: SCNNode) -> [SCNNode] {
		let directionalLight = createDirectionalLightNode()
		let node = setRotarionIfNeeded(configuration: configuration, center: center, rootNode: rootNode, lightNode: directionalLight)
		directionalLight.light?.castsShadow = configuration.isShadowEnabled
		return [node]
	}
	
	/// Настройка освещения под Ambient
	private func configureAmbientLight(configuration: LightsConfiguration, rootNode: SCNNode) -> [SCNNode] {
		let ambientLight = createAmbientLightNode()
		ambientLight.light?.castsShadow = configuration.isShadowEnabled
		rootNode.addChildNode(ambientLight)
		return [ambientLight]
	}
	
	/// Установка вращения узла по флагу isMotionEnabled. Возвращает верхний узел: орбиту или сам источник
	private func setRotarionIfNeeded(configuration: LightsConfiguration, center: SCNVector3, rootNode: SCNNode, lightNode: SCNNode) -> SCNNode {
		if configuration.isMotionEnabled {
			return self.rotationWorker.createRotation(
				node: lightNode,
				rootNode: rootNode,
				centerOrbit: center
			)
		} else {
			rootNode.addChildNode(lightNode)
			return lightNode
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
	
	func updateLights(configuration: LightsConfiguration, center: SCNVector3, radius: Float, rootNode: SCNNode) {
		debugPrint(#function)
	}
}
