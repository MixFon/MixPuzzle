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
	
	var settings = Settings()
	private let boxWorker: _BoxesWorker
	private var gameWorker: _GameWorker
	private let lightsWorker: _LightsWorker
	private let rotationWorker: _RotationWorker
	private let asteroidWorker: _AsteroidsWorker
	private let textNodeWorker: _TextNodeWorker
	private let startSceneModel: StartSceneModel?
	private var notificationCenter: NotificationCenter?
	
	private var cancellables = Set<AnyCancellable>()
	
	private let generator: UINotificationFeedbackGenerator?
	
	final class Settings {
		var isMoveOn = true
		var isShowAsteroids = true
		var allowsCameraControl: Bool = true
		var isUserInteractionEnabled: Bool = true
	}
	
	init(boxWorker: _BoxesWorker, generator: UINotificationFeedbackGenerator?, gameWorker: _GameWorker, lightsWorker: _LightsWorker, rotationWorker: _RotationWorker, asteroidWorker: _AsteroidsWorker, textNodeWorker: _TextNodeWorker, startSceneModel: StartSceneModel?, notificationCenter: NotificationCenter? = nil) {
		self.boxWorker = boxWorker
		self.generator = generator
		self.gameWorker = gameWorker
		self.lightsWorker = lightsWorker
		self.rotationWorker = rotationWorker
		self.asteroidWorker = asteroidWorker
		self.textNodeWorker = textNodeWorker
		self.startSceneModel = startSceneModel
		self.notificationCenter = notificationCenter
		
		configureSavePublisher()
		configureFinishPublisher()
		configureShowMenuPublisher()
		configureShowPathCompasses()
		configureRegeneratePublisher()
		configureShowSolutionPublisher()
		configureNotificationCenterPublisher()
		configureManageShakeAnimationPublisher()
		configureDeleteAllAnimationFromNodeSubject()
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
    
    func makeUIView(context: Context) -> SCNView {
		self.scene.rootNode.addChildNode(self.cameraNode)
		
		debugPrint(#function)
		self.lightsWorker.setupLights(
			center: self.boxWorker.centreMatrix,
			radius: self.boxWorker.radiusMatrix,
			rootNode: self.scene.rootNode
		)

		self.boxWorker.createMatrixBox(rootNode: self.scene.rootNode)
		createAndConfigureAsteroids()
		self.cameraNode.position = self.boxWorker.calculateCameraPosition()
		
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        self.scnView.addGestureRecognizer(tapGesture)
        return self.scnView
    }
	
	private func saveMatrix() {
		self.gameWorker.saveStatistics()
		self.gameWorker.saveCompasses()
		self.gameWorker.save(matrix: self.boxWorker.matrix)
	}
	
	private mutating func configureSavePublisher() {
		self.startSceneModel?.prepareCloseSubject.sink { [self] in
			self.asteroidWorker.deleteAsteroids()
			self.boxWorker.deleteAllBoxes()
			self.textNodeWorker.deleteNodesFormParent()
			saveMatrix()
		}.store(in: &cancellables)
	}
	
	/// Создаем поблишер который будте сохранять при сворачивании или при закрытии приложения
	private mutating func configureNotificationCenterPublisher() {
		self.notificationCenter?.publisher(for: UIApplication.didEnterBackgroundNotification).sink { [self] _ in
			saveMatrix()
		}.store(in: &cancellables)
	}
	
	/// Создаем паблишен, который будет показывать меню
	private mutating func configureShowMenuPublisher() {
		self.startSceneModel?.showMenuSubject.sink { [self] in
			self.textNodeWorker.createNodesInRandomPosition(rootNode: self.scene.rootNode)
			self.textNodeWorker.moveMenuTo(position: self.boxWorker.centreMatrix, rootNode: self.scene.rootNode)
			self.startSceneModel?.pathSolutionSubject.send(.menu)
			self.settings.isMoveOn = true
		}.store(in: &cancellables)
	}
	
	/// Создаем паблишен, который удаляет все анимации у кубиков
	private mutating func configureDeleteAllAnimationFromNodeSubject() {
		self.startSceneModel?.deleteAllAnimationFromNodeSubject.sink { [self] in
			self.boxWorker.deleteAnimationFromBoxes()
		}.store(in: &cancellables)
	}

	private mutating func configureFinishPublisher() {
		self.startSceneModel?.nextLavelSubject.sink { [self] in
			self.boxWorker.deleteAllBoxes()
			self.gameWorker.increaseLavel()
			self.gameWorker.regenerateMatrix()
			self.boxWorker.updateGrid(grid: Grid(matrix: self.gameWorker.matrix))
			self.boxWorker.createMatrixBox(rootNode: self.scene.rootNode)
			
			self.settings.isMoveOn = true
			self.startSceneModel?.pathSolutionSubject.send(.game)
			
			SCNTransaction.begin()
			SCNTransaction.animationDuration = 1.0 // продолжительность анимации

			self.scnView.pointOfView?.position = self.boxWorker.calculateCameraPosition()
			self.scnView.pointOfView?.eulerAngles = self.cameraNode.eulerAngles
			self.textNodeWorker.setPositionMenu(position: self.boxWorker.centreMatrix)
			
			SCNTransaction.commit()
			removeFinalMenu()
		}.store(in: &cancellables)
	}
	
	private mutating func configureRegeneratePublisher() {
		self.startSceneModel?.regenerateSubject.sink { [self] in
			self.gameWorker.statisticsWorker.increaseRegenerations()
			self.gameWorker.deleteCompasses()
			self.gameWorker.regenerateMatrix()
			
			self.boxWorker.updateGrid(grid: Grid(matrix: self.gameWorker.matrix))
			self.boxWorker.moveNodeToPointsOfGrid()
			
			self.startSceneModel?.pathSolutionSubject.send(.game)
			self.settings.isMoveOn = true
			removeFinalMenu()
		}.store(in: &cancellables)
	}
	
	private mutating func configureShowSolutionPublisher() {
		self.startSceneModel?.showSolution.sink { [self] bool in
			let matrix: Matrix
			if bool {
				self.gameWorker.updateMatrix(matrix: self.boxWorker.matrix)
				matrix = self.gameWorker.matrixSolution
			} else {
				matrix = self.gameWorker.matrix
			}
			self.boxWorker.updateGrid(grid: Grid(matrix: matrix))
			self.boxWorker.moveNodeToPointsOfGrid()
		}.store(in: &cancellables)
	}
	
	private mutating func configureManageShakeAnimationPublisher() {
		self.startSceneModel?.manageShakeAnimationSubject.sink { [self] mode in
			switch mode {
			case .start:
				self.boxWorker.runShakeAnimationForAllBoxes()
			case .stop(blendOutDuration: let blendOutDuration):
				self.boxWorker.stopShakeAnimationForAllBoxes(blendOutDuration: blendOutDuration)
			}
		}.store(in: &cancellables)
	}
	
	private mutating func configureShowPathCompasses() {
		self.startSceneModel?.pathSubject.sink { [self] compasses in
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
		self.startSceneModel?.disablePathButtonsViewSubject.send(true)
		self.scene.rootNode.runAction(SCNAction.sequence(actions)) {
			Task { @MainActor in
				self.startSceneModel?.disablePathButtonsViewSubject.send(false)
			}
		}
	}
		
	/// Удаление меню
	private func removeFinalMenu() {
		let deleteAction = self.textNodeWorker.createDeleteAnimationMenu()
		self.scene.rootNode.runAction(deleteAction) {
			self.textNodeWorker.deleteNodesFormParent()
		}
	}
    
    /// Создание и конфигурация астероидойдов
    private func createAndConfigureAsteroids() {
		guard self.settings.isShowAsteroids else { return }
        let centerMatrix = self.boxWorker.centreMatrix
		self.asteroidWorker.createAsteroids(rootNode: self.scene.rootNode, centerOrbit: centerMatrix)
    }
	
    func updateUIView(_ uiView: SCNView, context: Context) {
        // set the scene to the view
        uiView.scene = scene
        // allows the user to manipulate the camera
		uiView.allowsCameraControl = self.settings.allowsCameraControl
        // show statistics such as fps and timing information
        uiView.showsStatistics = false
        // configure the view
        uiView.backgroundColor = UIColor.black
		// Взаимоействие с объектами
		uiView.isUserInteractionEnabled = self.settings.isUserInteractionEnabled
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(gesture: handleTap)
    }
	
	private func handleTap(_ gestureRecognize: UIGestureRecognizer) {
		guard self.settings.isMoveOn else { return }
		// check what nodes are tapped
		let location = gestureRecognize.location(in: self.scnView)
		let hitResults = self.scnView.hitTest(location, options: [:])
		
		// Обработка результата нажатия
		if let hitNode = hitResults.first?.node {
			// Обнаружен узел, который был касаем
			self.generator?.prepare()
			if let hitNodeName = hitNode.name, let number = MatrixElement(hitNodeName) {
				// Проверка на то что мы нажали на кубик матрицы
				handleNodeOnMatrix(hitNode: hitNode, number: number)
			} else if self.textNodeWorker.isTextNode(node: hitNode) {
				// Проверка на то что нода относится к тексту меню
				handleMenuText(hitNode: hitNode)
			}
			
		}
	}
	
	/// Обработка кубика матрицы
	private func handleNodeOnMatrix(hitNode: SCNNode, number: MatrixElement) {
		if let moveToZeroAction = self.boxWorker.createMoveToZeroAction(number: number) {
			hitNode.runAction(moveToZeroAction)
			self.gameWorker.statisticsWorker.increaseSuccessfulMoves()
			if let compass = self.boxWorker.getCompass(for: number) {
				self.gameWorker.setCompass(compass: compass)
			}
			self.generator?.notificationOccurred(.success)
			checkSolution()
		} else {
			self.gameWorker.statisticsWorker.increaseFailedMoves()
			let shameAnimation = self.boxWorker.createShakeAnimation(position: hitNode.position)
			hitNode.addAnimation(shameAnimation, forKey: "shake")
			self.generator?.notificationOccurred(.error)
		}
	}
	
	/// Обработка ноды текста меню.
	private func handleMenuText(hitNode: SCNNode) {
		guard let hitName = hitNode.name, let textMenu = FinalMenuText(rawValue: hitName) else { return }
		switch textMenu {
		case .next:
			self.startSceneModel?.nextLavelSubject.send()
		case .retry:
			self.startSceneModel?.regenerateSubject.send()
		}
	}
	
	private func checkSolution() {
		if self.gameWorker.checkSolution(matrix: self.boxWorker.matrix) {
			self.gameWorker.statisticsWorker.increaseWins()
			self.gameWorker.saveStatistics()
			self.gameWorker.saveCompasses()
			let compasses = self.gameWorker.loadCompasses()
			self.startSceneModel?.compasses = compasses.reversed()
			self.startSceneModel?.compasses.append(.needle)
			self.startSceneModel?.pathSolutionSubject.send(.solution)
			self.settings.isMoveOn = false
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
