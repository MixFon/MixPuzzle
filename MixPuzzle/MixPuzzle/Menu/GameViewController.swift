//
//  GameViewController.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 10.02.2024.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
	
	private let scnView = SCNView()
	
	override func loadView() {
		self.view = scnView
	}
	
	func setupPhysicsForTextNode(_ textNode: SCNNode) {
		// Добавление физического тела
		textNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
		
		// Включение коллизий
		textNode.physicsBody?.contactTestBitMask = 0x1
		textNode.physicsBody?.collisionBitMask = 0x1
		
		// Установка категорий столкновений
		textNode.physicsBody?.categoryBitMask = 0x1
		
		// Настройка физических параметров (можете настроить под свои нужды)
		textNode.physicsBody?.mass = 1.0
		textNode.physicsBody?.friction = 0.5
	}
	
	func create3DText(text: String, font: UIFont, depth: CGFloat) -> SCNNode {
		// Создание геометрии текста
		   let textGeometry = SCNText(string: text, extrusionDepth: depth)
		   
		   // Установка шрифта для текста
		   textGeometry.font = font
		   
		   // Создание материала для текста
		   let material = SCNMaterial()
		   material.diffuse.contents = UIColor.white // цвет текста
		   textGeometry.materials = [material]
		   
		   // Создание узла с текстом
		   let textNode = SCNNode(geometry: textGeometry)
		   
		   // Установка физического тела
		   textNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
		   
		   return textNode
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "menu.scnassets/ship.scn")!
        
        // create and add a camera to the scene
//        let cameraNode = SCNNode()
//        cameraNode.camera = SCNCamera()
//        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
//        cameraNode.position = SCNVector3(x: 0, y: 0, z: 30)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
		
		// Пример использования
		let text = "H"
		let font = UIFont.systemFont(ofSize: 1.0) // Размер шрифта
		let depth: CGFloat = 0.1 // Глубина текста

		let textNode = create3DText(text: text, font: font, depth: depth)

		// Установка позиции текста
		textNode.position = SCNVector3(x: 0, y: 0, z: 10) // Например, переместим текст по оси Z на -5
		//setupPhysicsForTextNode(textNode)
		
		scene.rootNode.addChildNode(textNode)
        
        // retrieve the ship node
//        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
        // animate the 3d object
        //ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        // retrieve the SCNView
        //let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
