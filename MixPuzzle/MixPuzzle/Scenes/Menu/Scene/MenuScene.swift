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
	
	private let viewModel: MenuViewModel
    private let materialsWorker: _MaterialsWorker
    private var complition: (MenuSceneWrapper.Router) -> ()
	
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
			SeascapeWater.configure(node: floor)
		}
		// Волны анимируются в шейдере по времени, поэтому сцену нужно перерисовывать каждый кадр
		scnView.rendersContinuously = true
		configureCSNText(nodes: self.scene?.rootNode.childNodes ?? [])
		configureCameraLimits(context: context)
		return scnView
	}
	
	/// Не даем камере опуститься под воду.
	/// Вращение идет вокруг центра меню с ограничением угла над горизонтом, а для зума и панорамирования,
	/// которые эти углы не учитывают, координатор каждый кадр поднимает камеру до минимальной высоты
	private func configureCameraLimits(context: Context) {
		let target = SCNVector3(x: 0, y: 0, z: 0)
		// Углы в градусах над горизонтом. Строго сверху (90) — особая точка: там горизонтальный свайп
		// не облетает меню, а крутит картинку на месте, поэтому верхний предел чуть ниже
		let maximumVerticalAngle: Float = 85
		tiltStartCamera(to: maximumVerticalAngle, around: target)
		
		let cameraController = self.scnView.defaultCameraController
		cameraController.interactionMode = .orbitTurntable
		cameraController.target = target
		cameraController.minimumVerticalAngle = 10
		cameraController.maximumVerticalAngle = maximumVerticalAngle
		self.scnView.delegate = context.coordinator
	}
	
	/// В menu.scn камера смотрит строго сверху. Наклоняем ее на верхний предел, сохраняя расстояние до центра,
	/// чтобы при первом касании не было рывка к пределу
	private func tiltStartCamera(to degrees: Float, around target: SCNVector3) {
		guard let camera = self.scene?.rootNode.childNode(withName: "camera", recursively: false) else { return }
		let offset = SCNVector3(x: camera.position.x - target.x, y: camera.position.y - target.y, z: camera.position.z - target.z)
		let distance = sqrt(offset.x * offset.x + offset.y * offset.y + offset.z * offset.z)
		let angle = degrees * .pi / 180
		// Камера отходит к +Z и смотрит вниз-вперед на центр: верх кадра остается там же, где был
		camera.position = SCNVector3(x: target.x, y: target.y + distance * sin(angle), z: target.z + distance * cos(angle))
		camera.eulerAngles = SCNVector3(x: -angle, y: 0, z: 0)
	}
	
	private func configureCSNText(nodes: [SCNNode]) {
		// Порядок обусловнен порядком добавления нод в поддерево
		var displayName: [String] = [
			String(localized: "Start", comment: "Name node in menu scene"), // 0
			String(localized: "Options", comment: "Name node in menu scene"), // 2
			String(localized: "Find a solution", comment: "Name node in menu scene"), // 1
		]
		let metallTextures = ["MetalCorrodedHeavy001", "MetalGoldPaint002", "MetalZincGalvanized001"].randomElement() ?? "MetalCorrodedHeavy001"
		for node in nodes {
			if let textGeometry = node.geometry as? SCNText {
				textGeometry.string = displayName.removeFirst()
				textGeometry.font = UIFont(name: "AvenirNext-DemiBold", size: 30)
				let boundingBox = node.boundingBox
				let min = boundingBox.min
				let max = boundingBox.max
				
				// Рассчитываем размеры
				let width = Float(max.x - min.x)
				
				node.position = SCNVector3(x: -(width / 65), y: node.position.y, z: node.position.z)
				
				let configurationTexture = ConfigurationTexture(texture: metallTextures)
				// Важно: SCNText может иметь несколько материалов (для разных частей текста)
				// Лучше применить материал ко всем материалам текста
				textGeometry.materials.forEach { material in
					self.materialsWorker.configureMaterialDiffuse(material: material, texture: configurationTexture)
					self.materialsWorker.configureMaterial(material: material, texture: configurationTexture)
				}
				
				// Дополнительные настройки для лучшего отображения
				textGeometry.flatness = 0.1 // Уменьшаем для более гладкого текста
				textGeometry.chamferRadius = 0.9 // Добавляем скругление краёв
			}
		}
	}
	
	/// Пока меню закрыто другим экраном, не перерисовываем воду, чтобы не тратить батарею
	private mutating func configureFloorAnimationSubject() {
		self.viewModel.floorAnimationSubject.sink { [self] command in
			switch command {
			case .stop:
				self.scnView.rendersContinuously = false
			case .start:
				self.scnView.rendersContinuously = true
			}
		}.store(in: &self.cancellables)
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
	
	class Coordinator: NSObject, SCNSceneRendererDelegate {
		
		/// Минимальная высота камеры над водой. Волны поднимаются примерно на 0.75, а ближняя плоскость камеры — 1
		private static let minimumCameraHeight: Float = 3
		
		private let view: SCNView
		private let complition: (MenuSceneWrapper.Router) -> ()
		
        init(_ view: SCNView, complition: @escaping (MenuSceneWrapper.Router) -> ()) {
			self.view = view
            self.complition = complition
            super.init()
		}
		
		/// Вызывается на потоке рендера после применения жестов и ограничений, прямо перед отрисовкой кадра
		func renderer(_ renderer: any SCNSceneRenderer, didApplyConstraintsAtTime time: TimeInterval) {
			guard let camera = renderer.pointOfView else { return }
			let position = camera.worldPosition
			let minimumHeight = Self.minimumCameraHeight
			if position.y < minimumHeight {
				camera.worldPosition = SCNVector3(x: position.x, y: minimumHeight, z: position.z)
			}
		}
		
		@MainActor @objc
		func handleTap(_ gestureRecognize: UIGestureRecognizer) {
			// check what nodes are tapped
			let location = gestureRecognize.location(in: self.view)
			let hitResults = self.view.hitTest(location, options: [:])
			
			// Обработка результата нажатия
			if let hitNode = hitResults.first?.node {
				// Обнаружен узел, который был касаем
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
				
				hitNode.geometry?.firstMaterial?.emission.contents = UIColor.oceanColors.randomElement()
				
				SCNTransaction.commit()
			}
		}
	}
	
}
