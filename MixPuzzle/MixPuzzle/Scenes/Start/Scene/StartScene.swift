//
//  StartScene.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 24.02.2024.
//

import Combine
import SwiftUI
import SceneKit
import MFPuzzle
import Foundation

//struct StartSceneDependency {
//	
//}

struct StartScene: UIViewRepresentable {
	
	let boxWorker: _BoxesWorker
	let startsWorker: _AsteroidsWorker
    let settingsAsteroidsStorage: _SettingsAsteroidsStorage
	
	init(boxWorker: _BoxesWorker, startsWorker: _AsteroidsWorker, settingsAsteroidsStorage: _SettingsAsteroidsStorage) {
		self.boxWorker = boxWorker
		self.startsWorker = startsWorker
		self.settingsAsteroidsStorage = settingsAsteroidsStorage
	}
	
	private let generator = UINotificationFeedbackGenerator()
	
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
		lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
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
        // Добавление матрицы объектов
        let nodeBoxes = self.boxWorker.crateMatrixBox()
        nodeBoxes.forEach({ self.scene.rootNode.addChildNode($0) })
		
        if self.settingsAsteroidsStorage.isShowAsteroids {
            createAndConfigureAsteroids()
        }
		
        if self.cameraNode.camera?.fieldOfView != nil {
            self.cameraNode.position = self.boxWorker.calculateCameraPosition()
        }
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        self.scnView.addGestureRecognizer(tapGesture)
        return self.scnView
    }
    
    /// Создание и конфигурация астероидойдов
    private func createAndConfigureAsteroids() {
        let centerMatrix = self.boxWorker.centreMatrix
        let nodeStars = self.startsWorker.createAsteroids(centre: centerMatrix)
        nodeStars.forEach({
            configureStars(star: $0, centerRotation: centerMatrix)
        })
    }
    
    private func configureStars(star: SCNNode, centerRotation: SCNVector3) {
        let orbitNode = SCNNode()
        orbitNode.position = centerRotation
        self.scene.rootNode.addChildNode(orbitNode)
        self.scene.rootNode.addChildNode(star)
        orbitNode.addChildNode(star)
        self.startsWorker.setAnimationRotationTo(node: orbitNode)
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // set the scene to the view
        uiView.scene = scene
        // allows the user to manipulate the camera
        uiView.allowsCameraControl = true
        // show statistics such as fps and timing information
        uiView.showsStatistics = false
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
			self.generator.prepare()
		
			if let hitNodeName = hitNode.name, let number = UInt8(hitNodeName), let moveToZeroAction = self.boxWorker.createMoveToZeroAction(number: number) {
				hitNode.runAction(moveToZeroAction)
				self.generator.notificationOccurred(.success)
			} else {
				let shameAnimation = self.boxWorker.createShakeAnimation(position: hitNode.position)
				hitNode.addAnimation(shameAnimation, forKey: "shake")
				self.generator.notificationOccurred(.error)
			}
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
