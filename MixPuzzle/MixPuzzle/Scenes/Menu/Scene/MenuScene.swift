//
//  MenuScene.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 20.02.2024.
//

import Combine
import SwiftUI
import SceneKit
import Foundation

struct MenuScene: UIViewRepresentable {
	
	let viewModel: MenuViewModel
    let materialsWorker: _MaterialsWorker
    var complition: (MenuSceneWrapper.Router) -> ()
	
	private let scene = SCNScene(named: "puzzle.scnassets/menu.scn")
	private let scnView = SCNView()
	private var cancellables = Set<AnyCancellable>()
	
	private var floorNode: SCNNode? {
		self.scene?.rootNode.childNodes.first(where: { $0.name == "floor" } )
	}
	
	enum AnimationComand {
		case stop
		case start
	}
	
	init(viewModel: MenuViewModel, materialsWorker: _MaterialsWorker, complition: @escaping (MenuSceneWrapper.Router) -> Void) {
		self.viewModel = viewModel
		self.materialsWorker = materialsWorker
		self.complition = complition
		
		configureFloorAnimationSubject()
	}
	
	func makeUIView(context: Context) -> SCNView {
		let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
		scnView.addGestureRecognizer(tapGesture)
		if let floor = self.floorNode {
            setupFloor(floor: floor)
			//setupMovingAnimationFloor(floor: floor)
        }
		configureCSNText(nodes: self.scene?.rootNode.childNodes ?? [])
		return scnView
	}
	
	private func configureCSNText(nodes: [SCNNode]) {
		// Порядок обусловнен порядком добавления нод в поддерево
		var displayName: [String] = [
			"Start", // 0
			"Options", // 2
			"Find a solution" // 1
		]
		for node in nodes {
			if let textGeometry = node.geometry as? SCNText {
				textGeometry.string = displayName.removeFirst()
				let boundingBox = node.boundingBox
				let min = boundingBox.min
				let max = boundingBox.max
				
				// Рассчитываем размеры
				let width = Float(max.x - min.x)
				let height = Float(max.y - min.y)
				let length = Float(max.z - min.z)
				
				debugPrint("Width: \(width), Height: \(height), Length: \(length)")
				node.position = SCNVector3(x: -(width / 1) / 65, y: node.position.y, z: node.position.z)
			}
		}
	}
	
	private mutating func configureFloorAnimationSubject() {
		self.viewModel.floorAnimationSubject.sink { [self] command in
			switch command {
			case .stop:
				self.floorNode?.removeAllActions()
			case .start:
				if let floorNode = self.floorNode {
					setupMovingAnimationFloor(floor: floorNode)
				}
			}
		}.store(in: &self.cancellables)
	}
	
	/// Устанавливаем анимацию движения для пола
	private func setupMovingAnimationFloor(floor: SCNNode) {
		let moveLeft = SCNAction.moveBy(x: 0, y: 0, z: 5, duration: 5)
		let loop = SCNAction.repeatForever(moveLeft) // Зацикливаем
		floor.runAction(loop) // Запускаем анимацию
	}
    
	private func setupFloor(floor: SCNNode) {
        let configurationTexture = ConfigurationTexture(texture: "GroundGrassGreen002")
        guard let floorMaterial = floor.geometry?.firstMaterial else { return }
        self.materialsWorker.configureMaterial(material: floorMaterial, texture: configurationTexture)
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
        Coordinator(scnView, complition: self.complition)
	}
	
	class Coordinator: NSObject {
		
		private let view: SCNView
		private let complition: (MenuSceneWrapper.Router) -> ()
		
        init(_ view: SCNView, complition: @escaping (MenuSceneWrapper.Router) -> ()) {
			self.view = view
            self.complition = complition
            super.init()
		}
		
		@objc
		func handleTap(_ gestureRecognize: UIGestureRecognizer) {
			// check what nodes are tapped
			let location = gestureRecognize.location(in: self.view)
			let hitResults = self.view.hitTest(location, options: [:])
			
			// Обработка результата нажатия
			if let hitNode = hitResults.first?.node {
				// Обнаружен узел, который был касаем
				debugPrint("Node tapped: \(hitNode.name ?? "no name")")
                switch hitNode.name {
                case "start_node":
                    complition(.toStart)
                case "options_node":
                    complition(.toOprionts)
				case "find_solution_node":
					complition(.toFindSolution)
                default:
                    break
                }
				
				SCNTransaction.begin()
				SCNTransaction.animationDuration = 0.5
				
				// on completion - unhighlight
				SCNTransaction.completionBlock = {
					SCNTransaction.begin()
					SCNTransaction.animationDuration = 0.5
					
					hitNode.geometry?.firstMaterial?.emission.contents = UIColor.black
					
					SCNTransaction.commit()
				}
				
				hitNode.geometry?.firstMaterial?.emission.contents = UIColor.green
				
				SCNTransaction.commit()
			}
		}
	}
	
}
