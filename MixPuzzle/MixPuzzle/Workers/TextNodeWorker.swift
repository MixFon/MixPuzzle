//
//  TextNodeWorker.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 17.06.2024.
//

@preconcurrency import SceneKit
import Foundation

@MainActor
protocol _TextNodeWorker {
	var names: [String] { get }
	/// Создает анимацю переменуния текста относительно центра
	func moveMenuTo(position: SCNVector3, rootNode: SCNNode) async
	/// Пренадлежит ли нода к тексту из меню
	func isTextNode(node: SCNNode) -> Bool
	func createTextNode(text: String) -> SCNNode
	func createTextNode(text: String, position: SCNVector3) -> SCNNode
	/// Устанавливаем в меню в новую позицию
	func setPositionMenu(position: SCNVector3)
	func deleteNodesFormParent()
	/// Создает анимацю при удалении текста
	func createDeleteAnimationMenu() -> SCNAction?
	/// Создает ноды текта в слуайном месте
	func createNodesInRandomPosition(rootNode: SCNNode)

}

enum FinalMenuText: CaseIterable {
	/// Сдующий уровень
	case next
	/// Повторить текущий уровень
	case retry
	
	static func getCase(_ text: String) -> FinalMenuText? {
		switch text {
		case nextText: return .next
		case retryText: return .retry
		default : return nil
		}
	}
	
	var text: String {
		switch self {
		case .next: return FinalMenuText.nextText
		case .retry: return FinalMenuText.retryText
		}
	}
	
	private static var nextText: String {
		String(localized: "Raise the level", comment: "Text in final menu for case 'next'")
	}
		
	private static var retryText: String {
		String(localized: "Retry", comment: "Text in final menu for case 'retry'")
	}
	
}

final class TextNodeWorker: _TextNodeWorker {
	private let materialsWorker: any _MaterialsWorker
	private var textNodes: [SCNNode]?
	private let animationDuration: CGFloat = 0.1
	/// Расстояние между строками
	private let distanceBetweenLinesMenu: Float = 2.0
	
	private var randomPosition: SCNVector3 = {
		SCNVector3(x: Float.random(in: -20.0...20.0), y: Float.random(in: -20.0...20.0), z: 4)
	}()
		
	private lazy var metallTextures: String = {
		["MetalCorrodedHeavy001", "MetalGoldPaint002", "MetalZincGalvanized001"].randomElement() ?? "MetalCorrodedHeavy001"
	}()
	
	init(materialsWorker: any _MaterialsWorker) {
		self.materialsWorker = materialsWorker
	}

	var names: [String] {
		FinalMenuText.allCases.map({$0.text})
	}
	
	func isTextNode(node: SCNNode) -> Bool {
		FinalMenuText.allCases.contains(where: { $0.text == node.name} )
	}
	
	func createTextNode(text: String, position: SCNVector3) -> SCNNode {
		let textNode = createTextNode(text: text)
		textNode.position = position
		return textNode
	}
	
	func createTextNode(text: String) -> SCNNode {
		let textGeometry = SCNText(string: text, extrusionDepth: 1)
		textGeometry.font = UIFont(name: "AvenirNext-DemiBold", size: 2)
		let textNode = SCNNode(geometry: textGeometry)
		
		let configurationTexture = ConfigurationTexture(texture: self.metallTextures)
		// Важно: SCNText может иметь несколько материалов (для разных частей текста)
		// Лучше применить материал ко всем материалам текста
		textGeometry.materials.forEach { material in
			self.materialsWorker.configureMaterialDiffuse(material: material, texture: configurationTexture)
			self.materialsWorker.configureMaterial(material: material, texture: configurationTexture)
		}
		
		// Дополнительные настройки для лучшего отображения
		textGeometry.flatness = 0.9 // Уменьшаем для более гладкого текста
		textGeometry.chamferRadius = 0.1 // Добавляем скругление краёв
		return textNode
	}
	
	func createNodesInRandomPosition(rootNode: SCNNode) {
		guard self.textNodes == nil else { return }
		var nodes: [SCNNode] = []
		for text in FinalMenuText.allCases {
			let node = createTextNode(text: text.text, position: self.randomPosition)
			node.name = text.text
			nodes.append(node)
			rootNode.addChildNode(node)
		}
		self.textNodes = nodes
	}
	
	func moveMenuTo(position: SCNVector3, rootNode: SCNNode) async {
		guard let textNodes, let positions = createPositionForEachTextNode(position: position) else { return }
		var actions: [SCNAction] = []
		for (node, position) in zip(textNodes, positions) {
			let action = createAnimation(to: position, complerion: node.runAction)
			actions.append(action)
		}
		await rootNode.runAction(SCNAction.sequence(actions))
	}
	
	func setPositionMenu(position: SCNVector3) {
		guard let textNodes, let positions = createPositionForEachTextNode(position: position) else { return }
		for (node, position) in zip(textNodes, positions) {
			node.position = position
		}
	}
	
	func createDeleteAnimationMenu() -> SCNAction? {
		guard let textNodes else { return nil }
		var actions: [SCNAction] = []
		for node in textNodes {
			let action = createAnimation(to: self.randomPosition, complerion: node.runAction)
			actions.append(action)
		}
		return SCNAction.sequence(actions)
	}
	
	func deleteNodesFormParent() {
		self.textNodes?.forEach({ $0.removeFromParentNode() })
		self.textNodes = nil
	}
	
	private func createPositionForEachTextNode(position: SCNVector3) -> [SCNVector3]? {
		guard let textNodes else { return nil }
		var positions: [SCNVector3] = []
		for (i, node) in textNodes.enumerated() {
			let boundingBox = node.boundingBox
			let min = boundingBox.min
			let max = boundingBox.max
			
			// Рассчитываем размеры
			let width = Float(max.x - min.x)
			let position = SCNVector3(x: position.x - width / 2, y: position.y + (self.distanceBetweenLinesMenu * Float(i)), z: 4)
			positions.append(position)
		}
		return positions
	}
	
	private func createAnimation(to position: SCNVector3, complerion: @escaping (SCNAction) -> Void) -> SCNAction {
		func actionFunction(_ one: SCNNode,_ two: CGFloat) {
			let action = SCNAction.move(to: position, duration: self.animationDuration)
			complerion(action)
		}
		let customAction = SCNAction.customAction(duration: self.animationDuration, action: actionFunction)
		return customAction
	}
	
}

final class MockTextNodeWorker: _TextNodeWorker {
	var names: [String] = []
	
	func createTextNode(text: String) -> SCNNode {
		SCNNode()
	}
	
	func setPositionMenu(position: SCNVector3) {
		
	}

	func isTextNode(node: SCNNode) -> Bool {
		return true
	}
	
	func createTextNode(text: String, position: SCNVector3) -> SCNNode {
		SCNNode()
	}
	
	func createNodesInRandomPosition(rootNode: SCNNode) {
		
	}
	
	func moveMenuTo(position: SCNVector3, rootNode: SCNNode) async {
		
	}
	
	func createDeleteAnimationMenu() -> SCNAction? {
		return SCNAction()
	}
	
	func deleteNodesFormParent() {
		
	}
}
