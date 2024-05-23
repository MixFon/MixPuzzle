//
//  SettingsCubeScene.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 12.04.2024.
//

import Combine
import SwiftUI
import SceneKit
import MFPuzzle
import Foundation

struct SettingsCubeScene: UIViewRepresentable {
	
	private let model: SettingsCubeModel
	private let cubeWorker: _CubeWorker
	private let imageWorker: _ImageWorker
	
	private var cancellables = Set<AnyCancellable>()
	
	init(model: SettingsCubeModel, cubeWorker: _CubeWorker,imageWorker: _ImageWorker) {
		self.cubeWorker = cubeWorker
		self.model = model
		self.imageWorker = imageWorker
		self.scene.rootNode.addChildNode(self.cube)
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
		cameraNode.position = SCNVector3(x: 0, y: 0, z: 8)
		return cameraNode
	}()
	
	private let lightNode: SCNNode = {
		let lightNode = SCNNode()
		lightNode.light = SCNLight()
		lightNode.light?.type = .omni
		lightNode.position = SCNVector3(x: 0, y: 12, z: 12)
		return lightNode
	}()
	
	private let ambientLightNode: SCNNode = {
		let ambientLightNode = SCNNode()
		ambientLightNode.light = SCNLight()
		ambientLightNode.light?.type = .ambient
		ambientLightNode.light?.color = UIColor.darkGray.cgColor
		return ambientLightNode
	}()
	
	private lazy var cube: SCNNode = {
        let configurationCube = ConfigurationCube(
            texture: ConfigurationTexture(texture: "PlasticABSWorn001"),
            lengthEdge: 4,
            radiusChamfer: 1.0
        )
        let configurationImage = ConfigurationImage(
            size: 100.0,
            radius: 50.0,
            textImage: "21",
            colorLable: UIColor(Color.blue),
            nameImageTexture: configurationCube.texture.COL
        )
        let cube = self.cubeWorker.getCube(configurationCube: configurationCube, configurationImage: configurationImage)
		cube.position = SCNVector3(x: 0, y: 0, z: 0)
		configureImage(cube: cube)
		configureChamferRadius(cube: cube)
		return cube
	}()
	
	private mutating func configureImage(cube: SCNNode) {
		let worker = self.cubeWorker
		// Создаём поток, который срабатывает при изменении любого из четырех свойств
        Publishers.CombineLatest4(model.$radiusImage, model.$sizeImage, model.$colorLable, model.$texture)
			.sink(receiveValue: { (radius, size, lableColor, texture) in
                let configurationCube = ConfigurationCube(
                    texture: ConfigurationTexture(texture: texture),
                    lengthEdge: 4,
                    radiusChamfer: 1.0
                )
                let configurationImage = ConfigurationImage(
                    size: size,
                    radius: radius,
                    textImage: "21",
                    colorLable: UIColor(lableColor),
                    nameImageTexture: configurationCube.texture.COL
                )
                worker.changeImage(cube: cube, configurationCube: configurationCube, configuration: configurationImage)
			})
			.store(in: &cancellables)
	}
	
	private mutating func configureChamferRadius(cube: SCNNode) {
		let worker = self.cubeWorker
		self.model.$radiusChamfer.sink { _ in
			
		} receiveValue: { double in
			worker.changeChamferRadius(cube: cube, chamferRadius: double)
		}.store(in: &cancellables)
	}
	
	func makeUIView(context: Context) -> SCNView {
		self.scene.rootNode.addChildNode(self.lightNode)
		self.scene.rootNode.addChildNode(self.cameraNode)
		self.scene.rootNode.addChildNode(self.ambientLightNode)
		
		let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
		self.scnView.addGestureRecognizer(tapGesture)
		return self.scnView
	}
	
	func updateUIView(_ uiView: SCNView, context: Context) {
		// set the scene to the view
		uiView.scene = scene
		// allows the user to manipulate the camera
		uiView.allowsCameraControl = true
		// configure the view
		uiView.backgroundColor = UIColor.black
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(gesture: handleTap)
	}
	
	private func handleTap(_ gestureRecognize: UIGestureRecognizer) {
		// check what nodes are tapped
		let location = gestureRecognize.location(in: self.scnView)
		let hitResults = self.scnView.hitTest(location, options: [:])
		
		// Обработка результата нажатия
		if let _ = hitResults.first?.node {
			// Обнаружен узел, который был касаем
			
		}
	}

	class Coordinator: NSObject {
		
		private let gesture: (UIGestureRecognizer) -> ()
		
		init(gesture: @escaping (UIGestureRecognizer) -> ()) {
			self.gesture = gesture
			super.init()
		}
		
		@objc
		func handleTap(_ gestureRecognize: UIGestureRecognizer) {
			self.gesture(gestureRecognize)
		}
	}
	
}
