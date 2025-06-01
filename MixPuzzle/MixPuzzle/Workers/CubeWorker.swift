//
//  CubeWorker.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 14.04.2024.
//

import SceneKit
import Foundation

/// Отвечает за создание одного кубика
@MainActor
protocol _CubeWorker {
	/// Возвращает кубик с текстом-картинкой
	/// - configurationCube - конфигурация для геометрии кубика
	/// - configurationImage - конфигурации для изображения
    func getCube(configurationCube: ConfigurationCube, configurationImage: ConfigurationImage) -> SCNNode
	
	/// Изменение картинки с цислами на грани кубика
    func changeImage(cube: SCNNode, configurationCube: ConfigurationCube, configuration: ConfigurationImage)
	
	/// Изменение радиуса скругления куба
	func changeChamferRadius(cube: SCNNode, chamferRadius: Double)
}

struct ConfigurationTexture {
    let texture: String
    
    // Для цвета
    var COL: String {
        self.texture + "_COL"
    }
    /// Для нормали
    var NRM: String {
        self.texture + "_NRM"
    }
    /// Для отражения
    var REFL: String {
        self.texture + "_REFL"
    }
    /// Для отражения
    var DISP: String {
        self.texture + "_DISP"
    }
    /// Для глянца (specular)
    var GLOSS: String {
        self.texture + "_GLOSS"
    }
    /// Для шероховатости
    var ROUGHNESS: String {
        self.texture + "_ROUGHNESS"
    }
    /// Для металичность
    var METALNESS: String {
        self.texture + "_METALNESS"
    }
    /// Для Ambient Occlusion (Окружающая окклюзия)
    var AO: String {
        self.texture + "_AO"
    }
}

struct ConfigurationCube {
    let texture: ConfigurationTexture
    let lengthEdge: Float
    let radiusChamfer: Double
}

final class CubeWorker: _CubeWorker {
	
	/// Создание изображения по указанным параметрам
	private let imageWorker: _ImageWorker
    private let materialsWorker: _MaterialsWorker
	
	init(imageWorker: _ImageWorker, materialsWorker: _MaterialsWorker) {
		self.imageWorker = imageWorker
        self.materialsWorker = materialsWorker
	}
    
    func getCube(configurationCube: ConfigurationCube, configurationImage: ConfigurationImage) -> SCNNode {
        let boxNode = SCNNode()
        let lengthEdge = configurationCube.lengthEdge
		boxNode.geometry = SCNBox(width: CGFloat(lengthEdge), height: CGFloat(lengthEdge), length: CGFloat(lengthEdge), chamferRadius: configurationCube.radiusChamfer)
        
        //let im = UIImage(systemName: "\(box.number).circle.fill")
        let image = self.imageWorker.imageWith(configuration: configurationImage)
        
        let material = SCNMaterial()
        // Является базой для поверхности
        material.diffuse.contents = image
        
        self.materialsWorker.configureMaterial(material: material, texture: configurationCube.texture)
       
        boxNode.geometry?.firstMaterial = material
        return boxNode
    }
    
	func changeImage(cube: SCNNode, configurationCube: ConfigurationCube, configuration: ConfigurationImage) {
        let image = self.imageWorker.imageWith(configuration: configuration)
        if let material = cube.geometry?.firstMaterial {
            material.diffuse.contents = image
            self.materialsWorker.configureMaterial(material: material, texture: configurationCube.texture)
        }
	}
	
	func changeChamferRadius(cube: SCNNode, chamferRadius: Double) {
		let geometry = cube.geometry as? SCNBox
		geometry?.chamferRadius = chamferRadius
	}
}


final class MockCubeWorker: _CubeWorker {
	func getCube(configurationCube: ConfigurationCube, configurationImage: ConfigurationImage) -> SCNNode {
		return .init()
	}
	
	func changeImage(cube: SCNNode, configurationCube: ConfigurationCube, configuration: ConfigurationImage) {
		
	}
	
	func changeChamferRadius(cube: SCNNode, chamferRadius: Double) {
		
	}
}
