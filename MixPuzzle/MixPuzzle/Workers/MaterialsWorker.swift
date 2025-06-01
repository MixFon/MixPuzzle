//
//  MaterialsWorker.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 28.04.2024.
//

import SceneKit
import Foundation

@MainActor
protocol _MaterialsWorker {
    func configureMaterial(material: SCNMaterial, texture: ConfigurationTexture)
    func configureMaterialDiffuse(material: SCNMaterial, texture: ConfigurationTexture)
}

final class MaterialsWorker: _MaterialsWorker {
    
    func configureMaterialDiffuse(material: SCNMaterial, texture: ConfigurationTexture) {
        material.diffuse.contents = UIImage(named: texture.COL)
        configureMaterial(material: material, texture: texture)
    }
    
    func configureMaterial(material: SCNMaterial, texture: ConfigurationTexture) {
        // Отвечат за металический отблеск/глянец
        material.specular.contents = UIImage(named: texture.GLOSS)
        
        material.normal.contents = UIImage(named: texture.NRM)
        
        // Окружающая окклюзия
        material.ambientOcclusion.contents = UIImage(named: texture.AO)
        
        // Перемещение
        material.displacement.contents = UIImage(named: texture.DISP)
        material.displacement.intensity = 0
        
        // Отражение
        //material.reflective.contents = UIImage(named: texture.REFL)
        
        // Широховатость
        material.roughness.contents = UIImage(named: texture.ROUGHNESS)
        material.roughness.intensity = 0.5
        
        // Металичность
        material.metalness.contents = UIImage(named: texture.METALNESS)
        
        
        // Используется для затемнения или тонирования. Можно использовать как теневую карту
        //material.multiply.contents = UIImage(named: "RoofShinglesOld002_DISP_1K_METALNESS")
        
        // Можно имитировать облака
        //material.transparent.contents = UIImage(named: "RoofShinglesOld002_DISP_1K_METALNESS", in: nil, with: nil)
        //material.ambient.contents =
    }
}

final class MockMaterialsWorker: _MaterialsWorker {
	func configureMaterial(material: SCNMaterial, texture: ConfigurationTexture) {
		
	}
	
	func configureMaterialDiffuse(material: SCNMaterial, texture: ConfigurationTexture) {
		
	}
}
