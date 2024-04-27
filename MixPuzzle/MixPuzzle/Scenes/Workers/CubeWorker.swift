//
//  CubeWorker.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 14.04.2024.
//

import SceneKit
import Foundation

/// Отвечает за создание одного кубика
protocol _CubeWorker {
	/// Возвращает кубик с текстом-картинкой
	/// - textImage - текст который будет в круге
	/// - lengthEdge - длина ребра кубика
    func getCube(configurationCube: ConfigurationCube, configurationImage: ConfigurationImage) -> SCNNode
	
	/// Изменение радиуса на гране куба
    func changeImage(cube: SCNNode,configurationCube: ConfigurationCube, configuration: ConfigurationImage)
	
	/// Изменение радиуса скругления куба
	func changeChamferRadius(cube: SCNNode, chamferRadius: Double)
}

struct ConfigurationCube {
    let texture: String
    let lengthEdge: CGFloat
    let radiusChamfer: Double
    
    // Для цвета
    var textureCOL: String {
        self.texture + "_COL"
    }
    
    /// Для нормали
    var textureNRM: String {
        self.texture + "_NRM"
    }
    /// Для отражения
    var textureREFL: String {
        self.texture + "_REFL"
    }
    /// Для глянца (specular)
    var textureGLOSS: String {
        self.texture + "_GLOSS"
    }
    /// Для шероховатости
    var textureROUGHNESS: String {
        self.texture + "_ROUGHNESS"
    }
    /// Для металичность
    var textureMETALNESS: String {
        self.texture + "_METALNESS"
    }
    /// Для Ambient Occlusion (Окружающая окклюзия)
    var textureAO: String {
        self.texture + "_AO"
    }
}

final class CubeWorker: _CubeWorker {
	
	/// Создание изображения по указанным параметрам
	private let imageWorker: _ImageWorker
	
	init(imageWorker: _ImageWorker) {
		self.imageWorker = imageWorker
	}
    
    func getCube(configurationCube: ConfigurationCube, configurationImage: ConfigurationImage) -> SCNNode {
        let boxNode = SCNNode()
        let lengthEdge = configurationCube.lengthEdge
        boxNode.geometry = SCNBox(width: lengthEdge, height: lengthEdge, length: lengthEdge, chamferRadius: configurationCube.radiusChamfer)
        
        //let im = UIImage(systemName: "\(box.number).circle.fill")
        let image = self.imageWorker.imageWith(configuration: configurationImage)
        
        let material = SCNMaterial()
        // Является базой для поверхности
        material.diffuse.contents = image
        
        configureMaterial(material: material, configurationCube: configurationCube)
       
        boxNode.geometry?.firstMaterial = material
        return boxNode
    }
    
	func changeImage(cube: SCNNode, configurationCube: ConfigurationCube, configuration: ConfigurationImage) {
        let image = self.imageWorker.imageWith(configuration: configuration)
        if let material = cube.geometry?.firstMaterial {
            material.diffuse.contents = image
            configureMaterial(material: material, configurationCube: configurationCube)
        }
	}
	
	func changeChamferRadius(cube: SCNNode, chamferRadius: Double) {
		let geometry = cube.geometry as? SCNBox
		geometry?.chamferRadius = chamferRadius
	}
    
    private func configureMaterial(material: SCNMaterial, configurationCube: ConfigurationCube) {
        // Отвечат за металический отблеск/глянец
        material.specular.contents = UIImage(named: configurationCube.textureGLOSS)
        
        material.normal.contents = UIImage(named: configurationCube.textureNRM)
        
        // Окружающая окклюзия
        material.ambientOcclusion.contents = UIImage(named: configurationCube.textureAO)
        
        // Перемещение
        //material.displacement.contents = UIImage(named: "StuccoRoughCast001_DISP_1K_SPECULAR")
        
        // Отражение
        material.reflective.contents = UIImage(named: configurationCube.textureREFL)
        
        // Широховатость
        material.roughness.contents = UIImage(named: configurationCube.textureROUGHNESS)
        
        // Металичность
        material.metalness.contents = UIImage(named: configurationCube.textureMETALNESS)
        
        // Используется для затемнения или тонирования. Можно использовать как теневую карту
        //material.multiply.contents = UIImage(named: "RoofShinglesOld002_DISP_1K_METALNESS")
        
        // Можно имитировать облака
        //material.transparent.contents = UIImage(named: "RoofShinglesOld002_DISP_1K_METALNESS", in: nil, with: nil)
        //material.ambient.contents =
    }
}
