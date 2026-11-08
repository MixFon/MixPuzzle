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
	private let feedbackGenerator: _FeedbackGenerator
    private var complition: @MainActor (MenuSceneWrapper.Router) -> ()

	private let scene = SCNScene(named: "puzzle.scnassets/menu.scn")
	private let scnView = SCNView()

	private var floorNode: SCNNode? {
		self.scene?.rootNode.childNodes.first(where: { $0.name == "floor" } )
	}

	enum AnimationComand {
		case stop
		case start
	}

	/// Пункты меню: имя узла 3D-надписи в menu.scn, подпись и куда ведёт
	enum MenuItem: CaseIterable {
		case play
		case solution
		case settings

		var nodeName: String {
			switch self {
			case .play:
				return "start_node"
			case .solution:
				return "find_solution_node"
			case .settings:
				return "options_node"
			}
		}

		var title: String {
			switch self {
			case .play:
				return String(localized: "mix.menu.play", comment: "Menu item: start the game")
			case .solution:
				return String(localized: "mix.menu.solution", comment: "Menu item: find a solution")
			case .settings:
				return String(localized: "mix.menu.settings", comment: "Menu item: settings")
			}
		}

		var route: MenuSceneWrapper.Router {
			switch self {
			case .play:
				return .toStart
			case .solution:
				return .toFindSolution
			case .settings:
				return .toOprionts
			}
		}

		/// Разный период покачивания, чтобы надписи не двигались синхронно
		var bobDuration: TimeInterval {
			switch self {
			case .play:
				return 1.7
			case .solution:
				return 2.0
			case .settings:
				return 2.3
			}
		}

		init?(nodeName: String?) {
			guard let item = Self.allCases.first(where: { $0.nodeName == nodeName }) else { return nil }
			self = item
		}
	}

	/// Камера смотрит на центр меню сверху под этим углом (градусы над горизонтом)
	fileprivate static let cameraAngle: Float = 85
	/// С этого угла камера «влетает» к меню при открытии
	private static let introAngle: Float = 20
	private static let introDuration: TimeInterval = 2.2

	init(viewModel: MenuViewModel, materialsWorker: _MaterialsWorker, settingsGameStorage: _SettingsGameStorage, complition: @escaping @MainActor (MenuSceneWrapper.Router) -> Void) {
		self.viewModel = viewModel
		self.materialsWorker = materialsWorker
		self.feedbackGenerator = FeedbackGenerator(settingsGameStorage: settingsGameStorage)
		self.complition = complition
	}

	func makeUIView(context: Context) -> SCNView {
		let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
		scnView.addGestureRecognizer(tapGesture)
		// Двойной тап возвращает камеру в исходное положение. Одиночный тап его не ждёт,
		// чтобы переход по пункту меню не задерживался
		let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleDoubleTap(_:)))
		doubleTapGesture.numberOfTapsRequired = 2
		scnView.addGestureRecognizer(doubleTapGesture)
		if let floor = self.floorNode {
			SeascapeWater.configure(node: floor)
		}
		// Волны анимируются в шейдере по времени, поэтому сцену нужно перерисовывать каждый кадр
		scnView.rendersContinuously = true
		// Подписка живёт в координаторе: он один на всё время жизни SCNView,
		// а структуру MenuScene SwiftUI может пересоздать, и подписка из неё бы пропала
		context.coordinator.observeAnimationCommands(self.viewModel.floorAnimationSubject)
		configureMenuTexts()
		configureCameraLimits(context: context)
		playCameraIntro()
		return scnView
	}

	/// Не даем камере опуститься под воду.
	/// Вращение идет вокруг центра меню с ограничением угла над горизонтом, а для зума и панорамирования,
	/// которые эти углы не учитывают, координатор каждый кадр поднимает камеру до минимальной высоты
	private func configureCameraLimits(context: Context) {
		let target = SCNVector3(x: 0, y: 0, z: 0)
		// Углы в градусах над горизонтом. Строго сверху (90) — особая точка: там горизонтальный свайп
		// не облетает меню, а крутит картинку на месте, поэтому верхний предел чуть ниже
		let maximumVerticalAngle = Self.cameraAngle
		if let home = tiltStartCamera(to: maximumVerticalAngle, around: target) {
			context.coordinator.cameraHome = home
		}

		let cameraController = self.scnView.defaultCameraController
		cameraController.interactionMode = .orbitTurntable
		cameraController.target = target
		cameraController.minimumVerticalAngle = 10
		cameraController.maximumVerticalAngle = maximumVerticalAngle
		self.scnView.delegate = context.coordinator
	}

	/// В menu.scn камера смотрит строго сверху. Наклоняем ее на верхний предел, сохраняя расстояние до центра,
	/// чтобы при первом касании не было рывка к пределу
	/// - Returns: исходное положение камеры — к нему возвращает двойной тап
	@discardableResult
	private func tiltStartCamera(to degrees: Float, around target: SCNVector3) -> CameraPose? {
		guard let camera = self.cameraNode else { return nil }
		let offset = SCNVector3(x: camera.position.x - target.x, y: camera.position.y - target.y, z: camera.position.z - target.z)
		let distance = sqrt(offset.x * offset.x + offset.y * offset.y + offset.z * offset.z)
		let pose = CameraPose(degrees: degrees, distance: distance, target: target)
		camera.position = pose.position
		camera.eulerAngles = pose.eulerAngles
		return pose
	}

	private var cameraNode: SCNNode? {
		self.scene?.rootNode.childNode(withName: "camera", recursively: false)
	}

	/// При открытии камера плавно поднимается от горизонта к меню — сразу видно, что сцена объёмная
	private func playCameraIntro() {
		guard !UIAccessibility.isReduceMotionEnabled,
			  let camera = self.cameraNode else { return }
		let target = SCNVector3(x: 0, y: 0, z: 0)
		let home = CameraPose(degrees: Self.cameraAngle, distance: camera.position.length, target: target)
		let start = CameraPose(degrees: Self.introAngle, distance: home.distance, target: target)
		camera.position = start.position
		camera.eulerAngles = start.eulerAngles
		let move = SCNAction.move(to: home.position, duration: Self.introDuration)
		let rotate = SCNAction.rotateTo(x: CGFloat(home.eulerAngles.x), y: 0, z: 0, duration: Self.introDuration, usesShortestUnitArc: true)
		let intro = SCNAction.group([move, rotate])
		intro.timingMode = .easeInEaseOut
		camera.runAction(intro, forKey: "intro")
	}

	private func configureMenuTexts() {
		// Все надписи — одним материалом, чтобы меню выглядело одинаково при каждом запуске
		let configurationTexture = ConfigurationTexture(texture: "MetalGoldPaint002")
		for node in self.scene?.rootNode.childNodes ?? [] {
			guard let textGeometry = node.geometry as? SCNText,
				  let item = MenuItem(nodeName: node.name) else { continue }
			textGeometry.string = item.title
			textGeometry.font = UIFont(name: "AvenirNext-DemiBold", size: 30)
			let (min, max) = textGeometry.boundingBox

			// Рассчитываем размеры
			let width = Float(max.x - min.x)

			node.position = SCNVector3(x: -(width / 65), y: node.position.y, z: node.position.z)

			// Важно: SCNText может иметь несколько материалов (для разных частей текста)
			// Лучше применить материал ко всем материалам текста
			textGeometry.materials.forEach { material in
				self.materialsWorker.configureMaterialDiffuse(material: material, texture: configurationTexture)
				self.materialsWorker.configureMaterial(material: material, texture: configurationTexture)
			}

			// Дополнительные настройки для лучшего отображения
			textGeometry.flatness = 0.1 // Уменьшаем для более гладкого текста
			textGeometry.chamferRadius = 0.9 // Добавляем скругление краёв

			addHitArea(to: node, textBounds: (min, max))
			startBobbing(node: node, duration: item.bobDuration)
		}
	}

	/// Невидимая зона касания вокруг надписи: попасть можно не только по самим буквам
	private func addHitArea(to node: SCNNode, textBounds: (min: SCNVector3, max: SCNVector3)) {
		// Координаты — в единицах шрифта (узел надписи масштабирован), отступы — по 20 и 15 pt
		let width = CGFloat(textBounds.max.x - textBounds.min.x) + 40
		let height = CGFloat(textBounds.max.y - textBounds.min.y) + 30
		let box = SCNBox(width: width, height: height, length: 12, chamferRadius: 0)
		let material = SCNMaterial()
		// Не рисуется и не перекрывает воду, но участвует в hit test
		material.colorBufferWriteMask = []
		material.writesToDepthBuffer = false
		box.materials = [material]
		let hitArea = SCNNode(geometry: box)
		hitArea.name = "menu_hit_area"
		hitArea.position = SCNVector3(
			x: (textBounds.min.x + textBounds.max.x) / 2,
			y: (textBounds.min.y + textBounds.max.y) / 2,
			z: (textBounds.min.z + textBounds.max.z) / 2
		)
		node.addChildNode(hitArea)
	}

	/// Надпись мягко покачивается на воде
	private func startBobbing(node: SCNNode, duration: TimeInterval) {
		let up = SCNAction.moveBy(x: 0, y: 0.12, z: 0, duration: duration)
		up.timingMode = .easeInEaseOut
		let down = SCNAction.moveBy(x: 0, y: -0.12, z: 0, duration: duration)
		down.timingMode = .easeInEaseOut
		node.runAction(.repeatForever(.sequence([up, down])), forKey: "bob")
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
        Coordinator(scnView, feedbackGenerator: self.feedbackGenerator, complition: self.complition)
	}

	class Coordinator: NSObject, SCNSceneRendererDelegate {

		/// Минимальная высота камеры над водой. Волны поднимаются примерно на 0.75, а ближняя плоскость камеры — 1
		private static let minimumCameraHeight: Float = 3
		/// Пауза перед переходом, чтобы было видно нажатие
		private static let pressDelay: UInt64 = 250_000_000

		/// Исходное положение камеры — к нему возвращает двойной тап
		var cameraHome: CameraPose?

		private let view: SCNView
		private let feedbackGenerator: _FeedbackGenerator
		private let complition: @MainActor (MenuSceneWrapper.Router) -> ()
		private var animationCommandsCancellable: AnyCancellable?

        init(_ view: SCNView, feedbackGenerator: _FeedbackGenerator, complition: @escaping @MainActor (MenuSceneWrapper.Router) -> ()) {
			self.view = view
			self.feedbackGenerator = feedbackGenerator
            self.complition = complition
            super.init()
		}

		/// Команды «стоп/старт» от меню: когда меню закрыто другим экраном, сцена не должна рисоваться
		@MainActor
		func observeAnimationCommands(_ subject: PassthroughSubject<AnimationComand, Never>) {
			self.animationCommandsCancellable = subject.sink { [weak self] command in
				// Команды отправляются из SwiftUI на главном потоке
				MainActor.assumeIsolated {
					self?.apply(command)
				}
			}
		}

		/// Мало выключить постоянную отрисовку: SceneKit продолжает рисовать кадры, пока в сцене идут
		/// анимации (покачивание надписей, бесконечное), а с ними и шейдер воды. Поэтому сцену ставим на паузу.
		@MainActor
		private func apply(_ command: AnimationComand) {
			let isStopped = command == .stop
			self.view.scene?.isPaused = isStopped
			self.view.rendersContinuously = !isStopped
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

		/// Тап по надписи (или вокруг неё): надпись подпрыгивает, отдача, затем переход.
		/// Тап по воде ничего не делает.
		@MainActor @objc
		func handleTap(_ gestureRecognize: UIGestureRecognizer) {
			let location = gestureRecognize.location(in: self.view)
			let hitResults = self.view.hitTest(location, options: [:])
			guard let (node, item) = hitResults.lazy.compactMap({ Self.menuItem(containing: $0.node) }).first else { return }
			self.press(node)
			self.feedbackGenerator.emit()
			let route = item.route
			Task { @MainActor [complition] in
				try? await Task.sleep(nanoseconds: Self.pressDelay)
				complition(route)
			}
		}

		/// Двойной тап — плавно вернуть камеру в исходное положение
		@MainActor @objc
		func handleDoubleTap(_ gestureRecognize: UIGestureRecognizer) {
			guard let home = self.cameraHome, let camera = self.view.pointOfView else { return }
			camera.removeAction(forKey: "intro")
			SCNTransaction.begin()
			SCNTransaction.animationDuration = 0.6
			SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
			camera.position = home.position
			camera.eulerAngles = home.eulerAngles
			SCNTransaction.commit()
		}

		/// Узел надписи и пункт меню. Тап может попасть в зону касания — ищем вверх по дереву.
		private static func menuItem(containing node: SCNNode) -> (SCNNode, MenuItem)? {
			var current: SCNNode? = node
			while let candidate = current {
				if let item = MenuItem(nodeName: candidate.name) {
					return (candidate, item)
				}
				current = candidate.parent
			}
			return nil
		}

		/// Надпись «приседает» и подпрыгивает, на мгновение подсвечиваясь
		@MainActor
		private func press(_ node: SCNNode) {
			guard node.action(forKey: "press") == nil else { return }
			let squeeze = SCNAction.group([
				.scale(by: 0.9, duration: 0.08),
				.moveBy(x: 0, y: 0.35, z: 0, duration: 0.08),
			])
			let release = SCNAction.group([
				.scale(by: 1 / 0.9, duration: 0.2),
				.moveBy(x: 0, y: -0.35, z: 0, duration: 0.2),
			])
			release.timingMode = .easeOut
			node.runAction(.sequence([squeeze, release]), forKey: "press")

			let glow = UIColor.oceanColors.randomElement() ?? .cyan
			SCNTransaction.begin()
			SCNTransaction.animationDuration = 0.12
			node.geometry?.materials.forEach { $0.emission.contents = glow }
			SCNTransaction.completionBlock = {
				SCNTransaction.begin()
				SCNTransaction.animationDuration = 0.4
				node.geometry?.materials.forEach { $0.emission.contents = UIColor.black }
				SCNTransaction.commit()
			}
			SCNTransaction.commit()
		}
	}

}

/// Положение камеры на сфере вокруг центра меню
struct CameraPose {
	let degrees: Float
	let distance: Float
	let target: SCNVector3

	/// Камера отходит к +Z и смотрит вниз-вперед на центр: верх кадра остается там же, где был
	var position: SCNVector3 {
		let angle = self.degrees * .pi / 180
		return SCNVector3(
			x: self.target.x,
			y: self.target.y + self.distance * sin(angle),
			z: self.target.z + self.distance * cos(angle)
		)
	}

	var eulerAngles: SCNVector3 {
		SCNVector3(x: -self.degrees * .pi / 180, y: 0, z: 0)
	}
}

private extension SCNVector3 {
	var length: Float {
		sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
	}
}
