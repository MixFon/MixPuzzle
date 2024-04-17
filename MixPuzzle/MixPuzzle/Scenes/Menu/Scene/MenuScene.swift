//
//  MenuScene.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 20.02.2024.
//

import SwiftUI
import SceneKit
import Foundation

struct MenuScene: UIViewRepresentable {
	
    var complition: (MenuSceneWrapper.Router) -> ()
	
	private let scene = SCNScene(named: "puzzle.scnassets/menu.scn")
	private let scnView = SCNView()
	
	func makeUIView(context: Context) -> SCNView {
		let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
		scnView.addGestureRecognizer(tapGesture)
		return scnView
	}
	
	func updateUIView(_ uiView: SCNView, context: Context) {
		// set the scene to the view
		uiView.scene = scene
		
		// allows the user to manipulate the camera
		uiView.allowsCameraControl = true
		
		// show statistics such as fps and timing information
		uiView.showsStatistics = true
		
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
				print("Node tapped: \(hitNode.name ?? "no name")")
                switch hitNode.name {
                case "start_node":
                    complition(.toStart)
                case "options_node":
                    complition(.toOprionts)
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
