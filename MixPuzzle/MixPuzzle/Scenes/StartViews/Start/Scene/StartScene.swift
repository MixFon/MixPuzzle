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

struct StartScene: UIViewRepresentable {
	var isMoveOn = true
	var allowsCameraControl: Bool = true
	var isUserInteractionEnabled: Bool = true
	
	private let boxWorker: _BoxesWorker
	private let gameWorker: _GameWorker
	private let asteroidWorker: _AsteroidsWorker
	private let startSceneModel: StartSceneModel
    private let settingsAsteroidsStorage: _SettingsAsteroidsStorage
	
	private var cancellables = Set<AnyCancellable>()
	
	private let generator: UINotificationFeedbackGenerator?
	
	init(boxWorker: _BoxesWorker, generator: UINotificationFeedbackGenerator?, gameWorker: _GameWorker, asteroidWorker: _AsteroidsWorker, startSceneModel: StartSceneModel, settingsAsteroidsStorage: _SettingsAsteroidsStorage) {
		self.boxWorker = boxWorker
		self.generator = generator
		self.gameWorker = gameWorker
		self.asteroidWorker = asteroidWorker
		self.startSceneModel = startSceneModel
		self.settingsAsteroidsStorage = settingsAsteroidsStorage
		
		configureSavePublisher()
		configureShowPathCompasses()
		configureRegeneratePublisher()
		configureShowSolutionPublisher()
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
	
	private mutating func configureSavePublisher() {
		self.startSceneModel.saveSubject.sink { [self] in
			self.gameWorker.save(matrix: self.boxWorker.matrix)
		}.store(in: &cancellables)
	}
	
	private mutating func configureRegeneratePublisher() {
		self.startSceneModel.regenerateSubject.sink { [self] in
			self.gameWorker.regenerateMatrix()
			self.boxWorker.updateGrid(grid: Grid(matrix: self.gameWorker.matrix))
			self.moveNodeToNewPoints()
		}.store(in: &cancellables)
	}
	
	private mutating func configureShowSolutionPublisher() {
		self.startSceneModel.showSolution.sink { [self] bool in
			let matrix: Matrix
			if bool {
				self.gameWorker.updateMatrix(matrix: self.boxWorker.matrix)
				matrix = self.gameWorker.matrixSolution
			} else {
				matrix = self.gameWorker.matrix
			}
			self.boxWorker.updateGrid(grid: Grid(matrix: matrix))
			self.moveNodeToNewPoints()
		}.store(in: &cancellables)
	}
	
	private mutating func configureShowPathCompasses() {
		self.startSceneModel.pathSubject.sink { [self] compasses in
			createPathCompassesAnamations(compasses: compasses)
		}.store(in: &cancellables)
	}
	
	private func createPathCompassesAnamations(compasses: [Compass]) {
		var actions: [SCNAction] = []
		for compass in compasses {
			guard let number = self.boxWorker.getNumber(for: compass) else { continue }
			guard let node = self.scene.rootNode.childNodes.first(where: { $0.name == String(number) }) else { continue }
			guard let action = self.boxWorker.createCustomMoveToZeroAction(number: number, complerion: { node.runAction($0) }) else { continue }
			actions.append(action)
		}
		self.scene.rootNode.runAction(SCNAction.sequence(actions))
	}
	
	/// Перемещает кубики в новые позиции. Подразумевается, что уже будет новая Grid в
	private func moveNodeToNewPoints() {
		for node in self.scene.rootNode.childNodes {
			if let name = node.name, let number = UInt8(name), let action = self.boxWorker.createMoveToNumberAction(number: number) {
				node.runAction(action)
			}
		}
	}
    
    /// Создание и конфигурация астероидойдов
    private func createAndConfigureAsteroids() {
        let centerMatrix = self.boxWorker.centreMatrix
        let nodeStars = self.asteroidWorker.createAsteroids()
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
        self.asteroidWorker.setAnimationRotationTo(node: orbitNode)
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // set the scene to the view
        uiView.scene = scene
        // allows the user to manipulate the camera
		uiView.allowsCameraControl = self.allowsCameraControl
        // show statistics such as fps and timing information
        uiView.showsStatistics = false
        // configure the view
        uiView.backgroundColor = UIColor.black
		// Взаимоействие с объектами
		uiView.isUserInteractionEnabled = self.isUserInteractionEnabled
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(gesture: handleTap)
    }
	
	private func handleTap(_ gestureRecognize: UIGestureRecognizer) {
		guard self.isMoveOn else { return }
		// check what nodes are tapped
		let location = gestureRecognize.location(in: self.scnView)
		let hitResults = self.scnView.hitTest(location, options: [:])
		
		// Обработка результата нажатия
		if let hitNode = hitResults.first?.node {
			// Обнаружен узел, который был касаем
			self.generator?.prepare()
		
			if let hitNodeName = hitNode.name, let number = UInt8(hitNodeName), let moveToZeroAction = self.boxWorker.createMoveToZeroAction(number: number) {
				hitNode.runAction(moveToZeroAction)
				self.generator?.notificationOccurred(.success)
				checkSolution()
			} else {
				let shameAnimation = self.boxWorker.createShakeAnimation(position: hitNode.position)
				hitNode.addAnimation(shameAnimation, forKey: "shake")
				self.generator?.notificationOccurred(.error)
			}
		}
	}
	
	private func checkSolution() {
		if self.gameWorker.checkSolution(matrix: self.boxWorker.matrix) {
			print("Solution found!")
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
