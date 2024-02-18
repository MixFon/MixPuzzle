//
//  MenuController.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 10.02.2024.
//

import UIKit
import QuartzCore
import SceneKit

class MenuController: UIViewController {
	
	private let scnView = SCNView()
	
	override func loadView() {
		self.view = scnView
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SCNScene(named: "puzzle.scnassets/menu.scn")!
        
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
        // check what nodes are tapped
		let location = gestureRecognize.location(in: self.scnView)
		let hitResults = self.scnView.hitTest(location, options: [:])
		
		// Обработка результата нажатия
		if let hitNode = hitResults.first?.node {
			// Обнаружен узел, который был касаем
			print("Node tapped: \(hitNode.name ?? "no name")")
			
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
