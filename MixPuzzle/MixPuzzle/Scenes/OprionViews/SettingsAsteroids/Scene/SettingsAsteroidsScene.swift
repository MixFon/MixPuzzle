//
//  SettingsAsteroidsScene.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 24.10.2026.
//

import Combine
import SwiftUI
import SceneKit
import MFPuzzle
import Foundation

/// Сцена для живого превью настроек астероидов.
/// Повторяет игровую сцену в миниатюре: поле кубиков, свет и астероиды вокруг него
struct SettingsAsteroidsScene: UIViewRepresentable {
	
	private let model: SettingsAsteroidsModel
	private let boxesWorker: _BoxesWorker
	private let lightsWorker: _LightsWorker
	private let asteroidsWorker: _AsteroidsWorker
	
	private var cancellables = Set<AnyCancellable>()
	
	init(model: SettingsAsteroidsModel, boxesWorker: _BoxesWorker, lightsWorker: _LightsWorker, asteroidsWorker: _AsteroidsWorker) {
		self.model = model
		self.boxesWorker = boxesWorker
		self.lightsWorker = lightsWorker
		self.asteroidsWorker = asteroidsWorker
		
		self.lightsWorker.setupLights(
			center: self.boxesWorker.centreMatrix,
			radius: self.boxesWorker.radiusMatrix,
			rootNode: self.scene.rootNode
		)
		self.boxesWorker.createMatrixBox(rootNode: self.scene.rootNode)
		self.cameraNode.position = self.boxesWorker.calculateCameraPosition()
		self.scene.rootNode.addChildNode(self.cameraNode)
		
		configureAsteroids()
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
	
	/// Подписка на изменения настроек: при любом изменении приводим астероиды к новому состоянию
	private mutating func configureAsteroids() {
		let worker = self.asteroidsWorker
		let rootNode = self.scene.rootNode
		let centerOrbit = self.boxesWorker.centreMatrix
		Publishers.CombineLatest3(self.model.$asteroidsCount, self.model.$radiusSphere, self.model.$isShowAsteroids)
			.sink { count, radius, isShow in
				worker.updateAsteroids(
					count: isShow ? Int(count) : 0,
					radius: radius,
					rootNode: rootNode,
					centerOrbit: centerOrbit
				)
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
