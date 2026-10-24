//
//  SettingsLightScene.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 24.10.2026.
//

import Combine
import SwiftUI
import SceneKit
import MFPuzzle
import Foundation

/// Сцена для живого превью настроек освещения.
/// Показывает поле кубиков, как в игре, и пересоздает источники света при каждом изменении настроек
struct SettingsLightScene: UIViewRepresentable {
	
	private let model: SettingsLightModel
	private let boxesWorker: _BoxesWorker
	private let lightsWorker: _LightsWorker
	
	private var cancellables = Set<AnyCancellable>()
	
	init(model: SettingsLightModel, boxesWorker: _BoxesWorker, lightsWorker: _LightsWorker) {
		self.model = model
		self.boxesWorker = boxesWorker
		self.lightsWorker = lightsWorker
		
		self.boxesWorker.createMatrixBox(rootNode: self.scene.rootNode)
		self.cameraNode.position = self.boxesWorker.calculateCameraPosition()
		self.scene.rootNode.addChildNode(self.cameraNode)
		
		configureLights()
	}
	
	private let scene: SCNScene = {
		let scene = SCNScene()
		return scene
	}()
	
	private let scnView: SCNView = {
		let scnView = SCNView()
		return scnView
	}()
	
	private let cameraNode: SCNNode = {
		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		return cameraNode
	}()
	
	/// Подписка на изменения настроек: пересоздаем источники света, только когда конфигурация действительно изменилась.
	/// Ползунок количества шлет дробные значения на каждое движение, а в конфигурацию попадает целое число,
	/// поэтому повторы отбрасываем, иначе источники получали бы новые случайные позиции на каждом шаге ползунка
	private mutating func configureLights() {
		let worker = self.lightsWorker
		let rootNode = self.scene.rootNode
		let center = self.boxesWorker.centreMatrix
		let radius = self.boxesWorker.radiusMatrix
		Publishers.CombineLatest4(self.model.$lightType, self.model.$countLights, self.model.$isMotionEnabled, self.model.$isShadowEnabled)
			.map { lightType, countLights, isMotionEnabled, isShadowEnabled in
				LightsConfiguration(
					lightType: lightType,
					countLights: Int(countLights.rounded()),
					isMotionEnabled: isMotionEnabled,
					isShadowEnabled: isShadowEnabled
				)
			}
			.removeDuplicates()
			.sink { configuration in
				worker.updateLights(configuration: configuration, center: center, radius: radius, rootNode: rootNode)
			}
			.store(in: &self.cancellables)
	}
	
	func makeUIView(context: Context) -> SCNView {
		return self.scnView
	}
	
	func updateUIView(_ uiView: SCNView, context: Context) {
		// set the scene to the view
		uiView.scene = self.scene
		// allows the user to manipulate the camera
		uiView.allowsCameraControl = true
		// configure the view
		uiView.backgroundColor = UIColor.black
	}
}
