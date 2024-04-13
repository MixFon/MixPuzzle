//
//  SettingsCubeScene.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 12.04.2024.
//
import SwiftUI
import SceneKit
import MFPuzzle
import Foundation

struct SettingsCubeScene: UIViewRepresentable {
	
	let boxWorker: _BoxesWorker
	
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
	
	func makeUIView(context: Context) -> SCNView {
		self.scene.rootNode.addChildNode(self.lightNode)
		self.scene.rootNode.addChildNode(self.cameraNode)
		self.scene.rootNode.addChildNode(self.ambientLightNode)
		
		let cube = self.boxWorker.getBox(textImage: "21", lengthEdge: 4)
		cube.position = SCNVector3(x: 0, y: 0, z: 0)
		self.scene.rootNode.addChildNode(cube)
		self.cameraNode.position = SCNVector3(x: 0, y: 0, z: 8)
		
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
