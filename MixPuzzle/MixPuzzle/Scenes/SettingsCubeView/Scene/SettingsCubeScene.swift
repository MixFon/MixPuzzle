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
	
	private let cubeWorker: _CubeWorker
	private let dependency: SettingsCubeDependency
	private let imageWorker: _ImageWorker
	
	private var cancellables = Set<AnyCancellable>()
	
	init(cubeWorker: _CubeWorker,imageWorker: _ImageWorker, dependency: SettingsCubeDependency) {
		self.cubeWorker = cubeWorker
		self.dependency = dependency
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
		let cube = self.cubeWorker.getCube(textImage: "21", lengthEdge: 4)
		cube.position = SCNVector3(x: 0, y: 0, z: 0)
		configureRadiusImage(cube: cube)
		configureChamferRadius(cube: cube)
		return cube
	}()
	
	private mutating func configureRadiusImage(cube: SCNNode) {
		let worker = self.cubeWorker
		self.dependency.$radiusImage.sink { temp in
			print(temp)
		} receiveValue: { double in
			worker.changeRadiusForImage(cube: cube, radius: double)
		}.store(in: &cancellables)
	}
	
	private mutating func configureChamferRadius(cube: SCNNode) {
		let worker = self.cubeWorker
		self.dependency.$chamferRadius.sink { completion in
			print(completion)
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
		if let hitNode = hitResults.first?.node {
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
