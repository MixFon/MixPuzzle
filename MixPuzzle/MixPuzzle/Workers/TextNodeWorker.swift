//
//  TextNodeWorker.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 17.06.2024.
//

import SceneKit
import Foundation

protocol _TextNodeWorker {
	var names: [String] { get }
	/// Создает анимацю переменуния текста относительно центра
	func moveMenuTo(position: SCNVector3, rootNode: SCNNode)
	/// Пренадлежит ли нода к тексту из меню
	func isTextNode(node: SCNNode) -> Bool
	func createTextNode(text: String) -> SCNNode
	func createTextNode(text: String, position: SCNVector3) -> SCNNode
	/// Устанавливаем в меню в новую позицию
	func setPositionMenu(position: SCNVector3)
	func deleteNodesFormParent()
	/// Создает анимацю при удалении текста
	func createDeleteAnimationMenu() -> SCNAction
	/// Создает ноды текта в слуайном месте
	func createNodesInRandomPosition(rootNode: SCNNode)

}

enum FinalMenuText: String, CaseIterable {
	/// Сдующий уровень
	case next = "Raise the level"
	/// Повторить текущий уровень
	case retry = "Retry"
}

final class TextNodeWorker: _TextNodeWorker {
	private var textNodes: [SCNNode]?
	private let animationDuration: CGFloat = 0.1
	/// Расстояние между строками
	private let distanceBetweenLinesMenu: Float = 2.0
	
	lazy var randomPosition: SCNVector3 = {
		SCNVector3(x: Float.random(in: -20.0...20.0), y: Float.random(in: -20.0...20.0), z: 4)
	}()

	
	var names: [String] {
		FinalMenuText.allCases.map({$0.rawValue})
	}
	
	func isTextNode(node: SCNNode) -> Bool {
		FinalMenuText.allCases.contains(where: { $0.rawValue == node.name} )
	}
	
	func createTextNode(text: String, position: SCNVector3) -> SCNNode {
		let textNode = createTextNode(text: text)
		textNode.position = position
		return textNode
	}
	
	func createTextNode(text: String) -> SCNNode {
		let textGeometry = SCNText(string: text, extrusionDepth: 1)
		textGeometry.font = .systemFont(ofSize: 2)
		let textNode = SCNNode(geometry: textGeometry)
		return textNode
	}
	
	func createNodesInRandomPosition(rootNode: SCNNode) {
		guard self.textNodes == nil else { return }
		var nodes: [SCNNode] = []
		for text in FinalMenuText.allCases {
			let node = createTextNode(text: text.rawValue, position: self.randomPosition)
			node.name = text.rawValue
			nodes.append(node)
			rootNode.addChildNode(node)
		}
		self.textNodes = nodes
	}
	
	func moveMenuTo(position: SCNVector3, rootNode: SCNNode) {
		guard let textNodes else { return }
		var actions: [SCNAction] = []
		let positions = createPsitionForEachTextNode(position: position)
		for (node, position) in zip(textNodes, positions) {
			let action = createAnimation(to: position, complerion: { node.runAction($0) })
			actions.append(action)
		}
		rootNode.runAction(SCNAction.sequence(actions))
	}
	
	func setPositionMenu(position: SCNVector3) {
		guard let textNodes else { return }
		let positions = createPsitionForEachTextNode(position: position)
		for (node, position) in zip(textNodes, positions) {
			node.position = position
		}
	}
	
	func createDeleteAnimationMenu() -> SCNAction {
		var actions: [SCNAction] = []
		for node in self.textNodes ?? [] {
			let action = createAnimation(to: self.randomPosition, complerion: { node.runAction($0) })
			actions.append(action)
		}
		return SCNAction.sequence(actions)
	}
	
	func deleteNodesFormParent() {
		self.textNodes?.forEach({ $0.removeFromParentNode() })
		self.textNodes = nil
	}
	
	private func createPsitionForEachTextNode(position: SCNVector3) -> [SCNVector3] {
		guard let textNodes else { return [] }
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
		let customAction = SCNAction.customAction(duration: self.animationDuration, action: { [weak self] (_, _) in
			guard let self else { return }
			let action = SCNAction.move(to: position, duration: self.animationDuration)
			complerion(action)
		})
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
	
	func moveMenuTo(position: SCNVector3, rootNode: SCNNode) {
		
	}
	
	func createDeleteAnimationMenu() -> SCNAction {
		return SCNAction()
	}
	
	func deleteNodesFormParent() {
		
	}
}