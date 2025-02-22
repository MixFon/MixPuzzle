//
//  RotationWorker.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 26.12.2024.
//

import SceneKit
import Foundation

/// Протокол для создания вращения относительно центра с заданым радиусом
protocol _RotationWorker {
	@discardableResult
	func createRotation(node: SCNNode, rootNode: SCNNode, centerOrbit: SCNVector3) -> SCNNode
	func setAnimationRotationTo(node: SCNNode)
}

final class RotationWorker: _RotationWorker {
	/// Разброс смещения от точки центра берется случайное число из -delta...delta
	private let delta: Float = 3
	
	func createRotation(node: SCNNode, rootNode: SCNNode, centerOrbit: SCNVector3) -> SCNNode {
		let orbitNode = SCNNode()
		rootNode.addChildNode(orbitNode)
		rootNode.addChildNode(node)
		orbitNode.addChildNode(node)
		orbitNode.position = positionWithDelta(delta: self.delta, position: centerOrbit)
		setAnimationRotationTo(node: orbitNode)
		return orbitNode
	}
	
	/// Ставит анимацию вращения сферы вокруг узла
	func setAnimationRotationTo(node: SCNNode) {
		let a = Double.random(in: 1...3)
		let b = Double.random(in: 1...3)
		let c = Double.random(in: 1...3)
		let duration = Double.random(in: 40...50)
		let rotation = SCNAction.rotateBy(x: CGFloat(a * Double.pi), y: CGFloat(b * Double.pi), z: CGFloat(c * Double.pi), duration: duration)
		let repeatForever = SCNAction.repeatForever(rotation)
		node.runAction(repeatForever)
	}
	
	private func positionWithDelta(delta: Float, position: SCNVector3) -> SCNVector3 {
	   var positionDelta = SCNVector3()
	   positionDelta.x = position.x + Float.random(in: -delta...delta)
	   positionDelta.y = position.y + Float.random(in: -delta...delta)
	   positionDelta.z = position.z + Float.random(in: -delta...delta)
	   return positionDelta
   }
	
}

final class MockRotationWorker: _RotationWorker {
	func createRotation(node: SCNNode, rootNode: SCNNode, centerOrbit: SCNVector3) -> SCNNode {
		debugPrint(#function)
		return SCNNode()
	}
	
	func setAnimationRotationTo(node: SCNNode) {
		debugPrint(#function)
	}
}
