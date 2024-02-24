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
    
    var complition: (MenuView.Router) -> ()
    
    private struct Box {
        let x: Int
        let y: Int
        let number: Int
        let lengthEdge: Int
    }
    
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
        cameraNode.position = SCNVector3(x: 7, y: -7, z: 25)
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
        let worker = MatrixWorker()
        let matrixResult = worker.createMatrixSpiral(size: 4)
        let nodes = crateMatrixBox(matrix: matrixResult)
        nodes.forEach({ self.scene?.rootNode.addChildNode($0) })
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
    
    private func crateMatrixBox(matrix: Matrix) -> [SCNNode] {
        let lengthEdge = 4
        let delta = 1
        let size = matrix.count
        let edge = lengthEdge + delta
        var nodes = [SCNNode]()
        for i in 0..<size {
            for j in 0..<size {
                let number = Int(matrix[i][j])
                if number == 0 { continue }
                let box = Box(
                    x: i * edge,
                    y: j * edge,
                    number: number,
                    lengthEdge: lengthEdge
                )
                let node = getBox(box: box)
                nodes.append(node)
            }
        }
        return nodes
    }
    
    private func getBox(box: Box) -> SCNNode {
        let boxNode = SCNNode()
        let len = CGFloat(box.lengthEdge)
        boxNode.geometry = SCNBox(width: len, height: len, length: len, chamferRadius: 1)
        //let im = UIImage(systemName: "\(box.number).circle.fill")
        let im = UIImage(systemName: "12.circle.fill")
        
        let material = SCNMaterial()
        material.diffuse.contents = im
        material.specular.contents = UIImage(named: "bubble", in: nil, with: nil)
        //material.emission.contents = UIColor.red
        //material.ambient.contents =
        
        boxNode.geometry?.firstMaterial = material
        boxNode.position = SCNVector3(box.y, -box.x, 0)
        return boxNode
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
