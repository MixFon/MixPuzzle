//
//  StartScene.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 24.02.2024.
//

import SwiftUI
import SceneKit
import MFPuzzle
import Foundation

struct StartScene: UIViewRepresentable {
    
    let worker: _StartWorker
    let complition: (MenuView.Router) -> ()

    private let scene: SCNScene? = {
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
    
    private let lightNode: SCNNode = {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        return lightNode
    }()
    
    private let ambientLightNode: SCNNode = {
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray.cgColor
        return ambientLightNode
    }()
    
    func makeUIView(context: Context) -> SCNView {
        self.scene?.rootNode.addChildNode(self.lightNode)
        self.scene?.rootNode.addChildNode(self.cameraNode)
        self.scene?.rootNode.addChildNode(self.ambientLightNode)
        // Добавление матрицы объектов
        let nodeBoxes = self.worker.crateMatrixBox()
        nodeBoxes.forEach({ self.scene?.rootNode.addChildNode($0) })
        if let adge = self.cameraNode.camera?.fieldOfView {
            self.cameraNode.position = self.worker.calculateCameraPosition(adge: adge)
        }
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        self.scnView.addGestureRecognizer(tapGesture)
        return self.scnView
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
        private let complition: (MenuView.Router) -> ()
        
        init(_ view: SCNView, complition: @escaping (MenuView.Router) -> ()) {
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
