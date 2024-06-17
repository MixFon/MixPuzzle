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
	func createTextNode(text: String) -> SCNNode
	func createTextNode(text: String, position: SCNVector3) -> SCNNode
	func createFinalName(center: SCNVector3) -> [SCNNode]
}

final class TextNodeWorker: _TextNodeWorker {
	
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
	
	func createFinalName(center: SCNVector3) -> [SCNNode] {
		var nodes: [SCNNode] = []
		let delta: Float = 2.0
		for (i, text) in Text.allCases.enumerated() {
			let node = createTextNode(text: text.text)
			node.name = text.rawValue
			let boundingBox = node.boundingBox
			let min = boundingBox.min
			let max = boundingBox.max
			
			// Рассчитываем размеры
			let width = Float(max.x - min.x)
			
			node.position = SCNVector3(x: center.x - width / 2, y: center.y + (delta * Float(i)), z: 4)
			nodes.append(node)
		}
		return nodes
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
	
	func createFinalName(center: SCNVector3) -> [SCNNode] {
		[]
	}
}
