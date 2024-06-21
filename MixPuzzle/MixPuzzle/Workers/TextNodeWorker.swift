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
	func createMenu(centre: SCNVector3) -> SCNAction
	/// Создает анимацю при удалении текста
	func deleteMenu() -> SCNAction
	func deleteNodesFormParent()
	func createTextNode(text: String) -> SCNNode
	func createTextNode(text: String, position: SCNVector3) -> SCNNode
	/// Создает ноды текта в слуайном месте
	func createNodesInRandomPosition() -> [SCNNode]

}

final class TextNodeWorker: _TextNodeWorker {
	private var textNodes: [SCNNode] = []
	private let animationDuration: CGFloat = 0.1
	/// Расстояние между строками
	private let distanceBetweenLinesMenu: Float = 2.0
	
	lazy var randomPosition: SCNVector3 = {
		SCNVector3(x: Float.random(in: -20.0...20.0), y: Float.random(in: -20.0...20.0), z: 4)
	}()

	
	var names: [String] {
		Text.allCases.map({$0.rawValue})
	}
	
	private enum Text: String, CaseIterable {
		case new
		case next
		case retry
		
		var text: String {
			switch self {
			case .new: return "Another goal"
			case .next: return "Raise the level"
			case .retry: return "Retry"
			}
		}
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
	
	func createNodesInRandomPosition() -> [SCNNode] {
		var nodes: [SCNNode] = []
		for text in Text.allCases {
			let node = createTextNode(text: text.text, position: self.randomPosition)
			nodes.append(node)
		}
		self.textNodes = nodes
		return nodes
	}
	
	func createMenu(centre: SCNVector3) -> SCNAction {
		var actions: [SCNAction] = []
		for (i, node) in self.textNodes.enumerated() {
			let boundingBox = node.boundingBox
			let min = boundingBox.min
			let max = boundingBox.max
			
			// Рассчитываем размеры
			let width = Float(max.x - min.x)
			let position = SCNVector3(x: centre.x - width / 2, y: centre.y + (self.distanceBetweenLinesMenu * Float(i)), z: 4)
			let action = createAnimation(to: position, complerion: { node.runAction($0) })
			actions.append(action)
		}
		return SCNAction.sequence(actions)
	}
	
	func deleteMenu() -> SCNAction {
		var actions: [SCNAction] = []
		for node in self.textNodes {
			let action = createAnimation(to: self.randomPosition, complerion: { node.runAction($0) })
			actions.append(action)
		}
		return SCNAction.sequence(actions)
	}
	
	func deleteNodesFormParent() {
		self.textNodes.forEach({ $0.removeFromParentNode() })
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
	
	func createTextNode(text: String, position: SCNVector3) -> SCNNode {
		SCNNode()
	}
	
	func createNodesInRandomPosition() -> [SCNNode] {
		[]
	}
	
	func createMenu(centre: SCNVector3) -> SCNAction {
		return SCNAction()
	}
	
	func deleteMenu() -> SCNAction {
		return SCNAction()
	}
	
	func deleteNodesFormParent() {
	}
	

	

	
}
