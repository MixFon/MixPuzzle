//
//  BoxesWorker.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 25.02.2024.
//

import Combine
import MFPuzzle
import SceneKit

protocol _BoxesWorker {
	
	/// Матрица элементов. Двумерный массив
	var matrix: Matrix { get }
	/// Центр матрицы
	var centreMatrix: SCNVector3 { get }
	
	/// Создает матрицу кубиков с позицией, с геометрией и материалом.
	func createMatrixBox() -> [SCNNode]
	/// Создание анимации тряски кубика.
	func createShakeAnimation(position: SCNVector3) -> CAKeyframeAnimation
	/// Создает кубик в случайном месте
	func createBoxInRandomPlace(number: MatrixElement) -> SCNNode
	/// Опредляет координаты камеры так, чтобы все пазды были видны на экране
	func calculateCameraPosition() -> SCNVector3
	/// Создание анимации перемещения на узла на пустое место (на место нуля)
	func createMoveToZeroAction(number: MatrixElement) -> SCNAction?
	/// Создание анимации перемещения на узла на пустое место (на место нуля) по компасу
	func createMoveToZeroAction(compass: Compass) -> SCNAction?
	/// Создаем анимацию перемещения в позицию нода с номером number
	func createMoveToNumberAction(number: MatrixElement) -> SCNAction?
	/// Создаем собственной анимации перемещения в позицию нода с номером number. Для последовательных перемещений
	func createCustomMoveToZeroAction(number: MatrixElement, complerion: @escaping (SCNAction) -> Void) -> SCNAction?
	/// Обновление сетки
	func updateGrid(grid: Grid)
	/// Возвращает элемен по компасу, который находится около нуля
	func getNumber(for compass: Compass) -> MatrixElement?
	/// Возвращает компас для номера
	func getCompass(for number: MatrixElement) -> Compass?
}

/// Занимается созданием и UI настройкой матрицы элементов. Так же отвечает за пермещение элементов
final class BoxesWorker: _BoxesWorker {
	
	var matrix: Matrix {
		self.grid.matrix
	}
	/// Модель сетки, на основе нее строится отобрадение
	private var grid: Grid
    private let lengthEdge: CGFloat = 4
    private let verticalPadding: CGFloat = 0.4
	/// Длительность анимации передвижения в позицию 0
	private let animationDuration: TimeInterval = 0.2
    private let horisontalPadding: CGFloat = 0.2
	
	private let cubeWorker: _CubeWorker
    private let settingsCubeStorate: _SettingsCubeStorage
		
	var centreMatrix: SCNVector3 {
		let centreX = CGFloat(self.grid.size) * (self.lengthEdge + self.horisontalPadding) - self.horisontalPadding - self.lengthEdge
		let centreY = CGFloat(self.grid.size) * (self.lengthEdge + self.verticalPadding) - self.verticalPadding - self.lengthEdge
		return SCNVector3(x: Float(centreX / 2), y: Float(-centreY / 2), z: 0)
	}
    
    struct Box {
		let point: Point
        let number: Int
        let lengthEdge: CGFloat
		
		struct Point {
			let x: CGFloat
			let y: CGFloat
		}
    }
    
	init(grid: Grid, cubeWorker: _CubeWorker, settingsCubeStorate: _SettingsCubeStorage) {
        self.grid = grid
        self.cubeWorker = cubeWorker
        self.settingsCubeStorate = settingsCubeStorate
    }

    func createMatrixBox() -> [SCNNode] {
        return createNodesFormMatrix(matrix: self.grid.matrix)
    }
	
	func getNumber(for compass: Compass) -> MatrixElement? {
		return self.grid.getNumber(for: compass)
	}
	
	func getCompass(for number: MatrixElement) -> Compass? {
		return self.grid.getCompass(for: number)
	}
    
    func calculateCameraPosition() -> SCNVector3 {
		let centre = self.centreMatrix
		let height = CGFloat(self.grid.size) * (self.lengthEdge + self.horisontalPadding) + CGFloat(self.grid.size) * self.lengthEdge
		return SCNVector3(x: centre.x, y: centre.y, z: Float(height))
    }
	
	func createMoveToZeroAction(number: MatrixElement) -> SCNAction? {
		guard self.grid.isNeighbors(one: number, two: 0) == true else { return nil }
		guard let pointZero = self.grid.getPoint(number: 0) else { return nil }
		let boxPointZero = getBoxPoint(i: Int(pointZero.x), j: Int(pointZero.y))
		// Для векторов SCNVector3 на первом месте тоит Y на втором -X координаты из матрицы
		let action = SCNAction.move(to: SCNVector3(x: Float(boxPointZero.y), y: Float(-boxPointZero.x), z: 0), duration: self.animationDuration)
		self.grid.swapNumber(number: number)
		return action
	}
	
	func createCustomMoveToZeroAction(number: MatrixElement, complerion: @escaping (SCNAction) -> Void) -> SCNAction? {
		guard self.grid.isNeighbors(one: number, two: 0) == true else { return nil }
		guard let pointZero = self.grid.getPoint(number: 0) else { return nil }
		let boxPointZero = getBoxPoint(i: Int(pointZero.x), j: Int(pointZero.y))
		// Для векторов SCNVector3 на первом месте тоит Y на втором -X координаты из матрицы
		let customAction = SCNAction.customAction(duration: self.animationDuration, action: { [weak self] (_, _) in
			guard let self else { return }
			let action = SCNAction.move(to: SCNVector3(x: Float(boxPointZero.y), y: Float(-boxPointZero.x), z: 0), duration: self.animationDuration)
			complerion(action)
		})
		self.grid.swapNumber(number: number)
		return customAction
	}
	
	func createMoveToZeroAction(compass: Compass) -> SCNAction? {
		guard let number = self.grid.getNumber(for: compass) else { return nil }
		return createMoveToZeroAction(number: number)
	}
	
	func createMoveToNumberAction(number: MatrixElement) -> SCNAction? {
		guard let pointNumber = self.grid.getPoint(number: number) else { return nil }
		let boxPointZero = getBoxPoint(i: Int(pointNumber.x), j: Int(pointNumber.y))
		// Для векторов SCNVector3 на первом месте тоит Y на втором -X координаты из матрицы
		let action = SCNAction.move(to: SCNVector3(x: Float(boxPointZero.y), y: Float(-boxPointZero.x), z: 0), duration: self.animationDuration)
		return action
	}
	
	func createBoxInRandomPlace(number: MatrixElement) -> SCNNode {
		let i = Int.random(in: -100...100)
		let j = Int.random(in: -100...100)
		let configurationCube = ConfigurationCube(
			texture: ConfigurationTexture(texture: self.settingsCubeStorate.texture ?? ""),
			lengthEdge: self.lengthEdge,
			radiusChamfer: self.settingsCubeStorate.radiusChamfer
		)
		let box = Box(
			point: getBoxPoint(i: i, j: j),
			number: Int(number),
			lengthEdge: lengthEdge
		)
		let node = getBox(box: box, configurationCube: configurationCube)
		return node
	}
	
	func updateGrid(grid: Grid) {
		self.grid = grid
	}
	
	func createShakeAnimation(position vector: SCNVector3) -> CAKeyframeAnimation {
		let animation = CAKeyframeAnimation(keyPath: "position")
		let delta: Float = 0.2
		animation.values = [
			NSValue(scnVector3: SCNVector3(x: vector.x, y: vector.y, z: vector.z)),
			NSValue(scnVector3: SCNVector3(x: vector.x - delta, y: vector.y, z: vector.z)),
			NSValue(scnVector3: SCNVector3(x: vector.x + delta, y: vector.y, z: vector.z)),
			NSValue(scnVector3: SCNVector3(x: vector.x, y: vector.y, z: vector.z)),
			NSValue(scnVector3: SCNVector3(x: vector.x, y: vector.y - delta, z: vector.z)),
			NSValue(scnVector3: SCNVector3(x: vector.x, y: vector.y + delta, z: vector.z)),
			NSValue(scnVector3: SCNVector3(x: vector.x, y: vector.y, z: vector.z)),
		]
		animation.timingFunction = CAMediaTimingFunction(name: .linear)
		animation.duration = 0.2 // Продолжительность анимации
		animation.repeatCount = 1 // Количество повторений

		return animation
	}
	
	private func getBoxPoint(i: Int, j: Int) -> Box.Point {
		let verticalEdge = self.lengthEdge + self.verticalPadding
		let horisontalEdge = self.lengthEdge + self.horisontalPadding
		let point = Box.Point(
			x: CGFloat(i) * verticalEdge,
			y: CGFloat(j) * horisontalEdge
		)
		return point
	}
	
    private func createNodesFormMatrix(matrix: Matrix) -> [SCNNode] {
        var nodes = [SCNNode]()
        let configurationCube = ConfigurationCube(
            texture: ConfigurationTexture(texture: self.settingsCubeStorate.texture ?? ""),
            lengthEdge: self.lengthEdge,
            radiusChamfer: self.settingsCubeStorate.radiusChamfer
        )
        for (i, line) in matrix.enumerated() {
            for (j, number) in line.enumerated() {
                if number == 0 { continue }
                let box = Box(
					point: getBoxPoint(i: i, j: j),
                    number: Int(number),
                    lengthEdge: lengthEdge
                )
                let node = getBox(box: box, configurationCube: configurationCube)
                nodes.append(node)
            }
        }
        return nodes
    }
    
    private func getBox(box: Box, configurationCube: ConfigurationCube) -> SCNNode {
        let name = "\(box.number)"
        let configurationImage = ConfigurationImage(
            size: self.settingsCubeStorate.sizeImage,
            radius: self.settingsCubeStorate.radiusImage,
            textImage: name,
            colorLable: UIColor(self.settingsCubeStorate.colorLable ?? .blue),
            nameImageTexture: configurationCube.texture.COL
        )
		let boxNode = self.cubeWorker.getCube(configurationCube: configurationCube, configurationImage: configurationImage)
		boxNode.name = name
		boxNode.position = SCNVector3(box.point.y, -box.point.x, 0)
        return boxNode
    }

}
