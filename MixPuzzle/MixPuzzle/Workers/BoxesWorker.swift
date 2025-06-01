//
//  BoxesWorker.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 25.02.2024.
//

import Combine
import MFPuzzle
import SceneKit

@MainActor
protocol _BoxesWorker {
	
	/// Матрица элементов. Двумерный массив
	var matrix: Matrix { get }
	/// Радиус окружности описанной около матрицы
	var radiusMatrix: Float { get }
	/// Центр матрицы
	var centreMatrix: SCNVector3 { get }
	
	/// Удаление кубиков со сцены
	func deleteAllBoxes()
	/// Создает матрицу кубиков с позицией, с геометрией и материалом.
	func createMatrixBox(rootNode: SCNNode)
	/// Создание анимации тряски кубика.
	func createShakeAnimation(position: SCNVector3) -> CAKeyframeAnimation
	/// Перемещает кубики в позиции соответствующие Grid. Подразумевается, что уже будет новая Grid в gameWorker
	func moveNodeToPointsOfGrid()
	/// Перемещает кубики в позиции соответствующие targetMatrix
	func moveNodesToTargetPozitions(targetMatrix: Matrix, completion: @escaping () -> Void)
	/// Создает кубик в случайном месте
	func createBoxInRandomPlace(number: MatrixElement) -> SCNNode
	/// Опредляет координаты камеры так, чтобы все пазды были видны на экране
	func calculateCameraPosition() -> SCNVector3
	/// Создание анимации перемещения узла на пустое место (на место нуля)
	func createMoveToZeroAction(number: MatrixElement) -> SCNAction?
	/// Создание анимации перемещения на узла на пустое место (на место нуля) по компасу
	func createMoveToZeroAction(compass: Compass) -> SCNAction?
	/// Создаем анимацию перемещения в позицию нода с номером number
	func createMoveToNumberAction(number: MatrixElement) -> SCNAction?
	/// Создаем собственной анимации перемещения в позицию нода с номером number. Для последовательных перемещений
	func createCustomMoveToZeroAction(number: MatrixElement, complerion: @escaping (SCNAction) -> Void) -> SCNAction?
	/// Запускаю анимацию тряски для всехкубиков
	func runShakeAnimationForAllBoxes()
	/// Останавливаю анимацию тряски для всехкубиков
	func stopShakeAnimationForAllBoxes(blendOutDuration: CGFloat?)
	/// Обновление сетки
	func updateGrid(grid: Grid<MatrixElement>)
	/// Возвращает элемен по компасу, который находится около нуля
	func getNumber(for compass: Compass) -> MatrixElement?
	/// Возвращает компас для номера
	func getCompass(for number: MatrixElement) -> Compass?
	/// Удаляем все анимации у кубиков
	func deleteAnimationFromBoxes()
}

/// Занимается созданием и UI настройкой матрицы элементов. Так же отвечает за пермещение элементов
final class BoxesWorker: _BoxesWorker {

	var matrix: Matrix {
		self.grid.matrix
	}
	
	/// Модель сетки, на основе нее строится отобрадение
	private var grid: Grid<MatrixElement>
	private var boxesNode: [SCNNode]?
    private let lengthEdge: Float = 4
	private let transporter: any _Transporter
	/// Ключ для анимации тряски
	private let keyForGroupAnimation: String = "mix.animation.group"
	/// Длительность анимации передвижения в позицию 0
	private let animationDuration: TimeInterval = 0.3
	
	private let deepPadding: Float = 0
	private let verticalPadding: Float = 0.4
    private let horisontalPadding: Float = 0.2

	private let cubeWorker: _CubeWorker
    private let settingsCubeStorate: _SettingsCubeStorage
	
	private var widthMatrix: Float {
		Float(self.grid.size) * (self.lengthEdge + self.horisontalPadding) - self.horisontalPadding - self.lengthEdge
	}
	
	private var heightMatrix: Float {
		Float(self.grid.size) * (self.lengthEdge + self.verticalPadding) - self.verticalPadding - self.lengthEdge
	}
		
	var centreMatrix: SCNVector3 {
		return SCNVector3(x: self.widthMatrix / 2.0, y: -self.heightMatrix / 2.0, z: 0)
	}
	
	var radiusMatrix: Float {
		return sqrt(self.widthMatrix * self.widthMatrix + self.heightMatrix * self.heightMatrix) / 2.0
	}
    
    struct Box {
		let point: Point
        let number: Int
        let lengthEdge: Float
		
		struct Point {
			let x: Float
			let y: Float
			var z: Float = 0
		}
    }
    
	init(grid: Grid<MatrixElement>, cubeWorker: any _CubeWorker, transporter: some _Transporter, settingsCubeStorate: any _SettingsCubeStorage) {
        self.grid = grid
        self.cubeWorker = cubeWorker
		self.transporter = transporter
        self.settingsCubeStorate = settingsCubeStorate
    }
	
	func deleteAllBoxes() {
		self.boxesNode?.forEach { $0.removeFromParentNode() }
		self.boxesNode = nil
	}
	
	func deleteAnimationFromBoxes() {
		self.boxesNode?.forEach { $0.removeAllActions() }
	}
	
	func moveNodesToTargetPozitions(targetMatrix: Matrix, completion: @escaping () -> Void) {
		do {
			let currentMatrix = convertToIntMatrix(matrix: self.grid.matrix)
			let goalMatrix = convertToIntMatrix(matrix: targetMatrix)
			let pathsDirections = try self.transporter.createDirections(from: currentMatrix, to: goalMatrix)
			let allMatrixElements = self.grid.matrix.flatMap { $0 }.map({ Int($0) })
			// Счетчик для вызова completion после завершения всех анимаций
			let dispatchGroup = DispatchGroup()
			
			for element in allMatrixElements {
				guard let action = createAction(for: element, with: pathsDirections[element] ?? []), !action.isEmpty else { continue }
				let node = self.boxesNode?.first(where: {$0.name == String(element)})
				dispatchGroup.enter()
				node?.runAction(SCNAction.sequence(action)) {
					dispatchGroup.leave()
				}
			}
			dispatchGroup.notify(queue: .main) {
				completion()
			}
		} catch {
			// Так как ошибки в createDirections выбрасываются очень редко перезапускам метод
			moveNodesToTargetPozitions(targetMatrix: targetMatrix, completion: completion)
		}
	}
	
	/// Создает посделовательность перемещений на основе Directions для element
	private func createAction(for element: Int, with directions: [Direction]) -> [SCNAction]? {
		guard let pointElement = self.grid.getPoint(number: MatrixElement(element)) else { return nil }
		var point3D = Grid3DPoint(x: pointElement.x, y: pointElement.y, z: 0)
		var actions: [SCNAction] = []
		let duration: TimeInterval = 0.3
		let waitAction = SCNAction.wait(duration: 0.1)
		for direction in directions {
			switch direction {
			case .up(let upDirection):
				if let upDirection = upDirection {
					let upActions = complicatedMoveToAction(point3D: &point3D, duration: duration, directionFirst: .up(nil), directionSecond: upDirection)
					actions.append(contentsOf: upActions)
				} else {
					actions.append(simpleMoveToAction(point3D: &point3D, duration: duration, direction: direction))
				}
			case .down(let downDirection):
				if let downDirection = downDirection {
					let downActions = complicatedMoveToAction(point3D: &point3D, duration: duration, directionFirst: .down(nil), directionSecond: downDirection)
					actions.append(contentsOf: downActions)
				} else {
					actions.append(simpleMoveToAction(point3D: &point3D, duration: duration, direction: direction))
				}
			default:
				actions.append(simpleMoveToAction(point3D: &point3D, duration: duration, direction: direction))
			}
			actions.append(waitAction)
			
		}
		return actions
	}
	
	private func complicatedMoveToAction(point3D: inout Grid3DPoint, duration: TimeInterval, directionFirst: Direction, directionSecond: Direction) -> [SCNAction] {
		point3D = point3D.getByAdding(from: directionFirst)
		var point = getBoxPoint(i: Int(point3D.x), j: Int(point3D.y), k: Int(point3D.z))
		// Для векторов SCNVector3 на первом месте тоит Y на втором -X координаты из матрицы
		let firstAction = SCNAction.move(to: SCNVector3(x: Float(point.y), y: Float(-point.x), z: Float(-point.z)), duration: duration / 2)

		point3D = point3D.getByAdding(from: directionSecond)
		point = getBoxPoint(i: Int(point3D.x), j: Int(point3D.y), k: Int(point3D.z))
		// Для векторов SCNVector3 на первом месте тоит Y на втором -X координаты из матрицы
		let secondAction = SCNAction.move(to: SCNVector3(x: Float(point.y), y: Float(-point.x), z: Float(-point.z)), duration: duration / 2)
		return [firstAction, secondAction]
	}
	
	private func simpleMoveToAction(point3D: inout Grid3DPoint, duration: TimeInterval, direction: Direction) -> SCNAction {
		point3D = point3D.getByAdding(from: direction)
		let boxPoint = getBoxPoint(i: Int(point3D.x), j: Int(point3D.y), k: Int(point3D.z))
		// Для векторов SCNVector3 на первом месте тоит Y на втором -X координаты из матрицы
		let action = SCNAction.move(to: SCNVector3(x: Float(boxPoint.y), y: Float(-boxPoint.x), z: Float(-boxPoint.z)), duration: duration)
		return action
	}
	
	func moveNodeToPointsOfGrid() {
		guard let boxesNode else { return }
		for node in boxesNode {
			if let name = node.name, let number = MatrixElement(name), let action = createMoveToNumberAction(number: number) {
				node.runAction(action)
			}
		}
	}

    func createMatrixBox(rootNode: SCNNode) {
		let boxes = createNodesFormMatrix(matrix: self.grid.matrix)
		self.boxesNode = boxes
		boxes.forEach { rootNode.addChildNode($0) }
    }
	
	func getNumber(for compass: Compass) -> MatrixElement? {
		return self.grid.getNumber(for: compass)
	}
	
	func getCompass(for number: MatrixElement) -> Compass? {
		return self.grid.getCompass(for: number)
	}
    
    func calculateCameraPosition() -> SCNVector3 {
		let centre = self.centreMatrix
		let height = Float(self.grid.size) * (self.lengthEdge + self.horisontalPadding) + Float(self.grid.size) * self.lengthEdge
		return SCNVector3(x: centre.x, y: centre.y, z: Float(height))
    }
	
	func createMoveToZeroAction(number: MatrixElement) -> SCNAction? {
		guard self.grid.isNeighbors(one: number, two: 0) == true else { return nil }
		guard let pointZero = self.grid.getPoint(number: 0) else { return nil }
		let boxPointZero = getBoxPoint(i: Int(pointZero.x), j: Int(pointZero.y))
		// Для векторов SCNVector3 на первом месте стоит Y на втором -X координаты из матрицы
		let action = SCNAction.move(to: SCNVector3(x: Float(boxPointZero.y), y: Float(-boxPointZero.x), z: 0), duration: self.animationDuration)
		self.grid.swapNumber(number: number, target: 0)
		return action
	}
	
	func createCustomMoveToZeroAction(number: MatrixElement, complerion: @escaping (SCNAction) -> Void) -> SCNAction? {
		guard self.grid.isNeighbors(one: number, two: 0) == true else { return nil }
		guard let pointZero = self.grid.getPoint(number: 0) else { return nil }
		let boxPointZero = getBoxPoint(i: Int(pointZero.x), j: Int(pointZero.y))
		// Для векторов SCNVector3 на первом месте тоит Y на втором -X координаты из матрицы
		// Длительность customAction должна быть больше чем длительность action. Это нужно чтобы кубики не наслаивались друг на друга
		let customAction = SCNAction.customAction(duration: 0.2, action: { (_, _) in
			let action = SCNAction.move(to: SCNVector3(x: Float(boxPointZero.y), y: Float(-boxPointZero.x), z: 0), duration: 0.1)
			complerion(action)
		})
		self.grid.swapNumber(number: number, target: 0)
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
	
	func updateGrid(grid: Grid<MatrixElement>) {
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
	
	func runShakeAnimationForAllBoxes() {
		self.boxesNode?.forEach( {addComplexShakeAnimation(to: $0)} )
	}
	
	func stopShakeAnimationForAllBoxes(blendOutDuration: CGFloat?) {
		if let blendOutDuration {
			self.boxesNode?.forEach( {$0.removeAnimation(forKey: self.keyForGroupAnimation, blendOutDuration: blendOutDuration)})
		} else {
			self.boxesNode?.forEach( {$0.removeAnimation(forKey: self.keyForGroupAnimation)})
		}
	}
	
	/// Перевод матрицы в двумерный массив Int
	private func convertToIntMatrix(matrix: Matrix) -> [[Int]] {
		var result: [[Int]] = []
		for row in matrix {
			let line = row.map({Int($0)})
			result.append(line)
		}
		return result
	}
	
	private func addComplexShakeAnimation(to node: SCNNode) {
		// Анимация смещения вдоль осей OX и OY
		let positionAnimation = CAKeyframeAnimation(keyPath: "position")
		let originalPosition = node.position
		
		let delta = Float.random(in: -0.3...0.3)
		
		// Значения для смещения
		positionAnimation.values = [
			SCNVector3(originalPosition.x, originalPosition.y, originalPosition.z),
			SCNVector3(originalPosition.x + delta, originalPosition.y + delta, originalPosition.z),
			SCNVector3(originalPosition.x - delta, originalPosition.y - delta, originalPosition.z),
			SCNVector3(originalPosition.x + delta, originalPosition.y - delta, originalPosition.z),
			SCNVector3(originalPosition.x - delta, originalPosition.y + delta, originalPosition.z),
			SCNVector3(originalPosition.x, originalPosition.y, originalPosition.z)
		]
		positionAnimation.duration = 0.25
		positionAnimation.repeatCount = 4
		
		let deltaAngle = Float.random(in: 12...18)

		// Анимация вращения вокруг оси Z
		let rotationAnimation = CAKeyframeAnimation(keyPath: "rotation")
		rotationAnimation.values = [
			SCNVector4(0, 0, 1, 0),
			SCNVector4(0, 0, 1, Float.pi / deltaAngle),
			SCNVector4(0, 0, 1, -Float.pi / deltaAngle),
			SCNVector4(0, 0, 1, 0)
		]
		rotationAnimation.duration = 0.25
		rotationAnimation.repeatCount = 4
		
		// Группируем анимации
		let group = CAAnimationGroup()
		group.animations = [positionAnimation, rotationAnimation]
		group.duration = 0.5
		group.repeatCount = Float.infinity
		
		// Добавляем анимацию к узлу
		node.addAnimation(group, forKey: self.keyForGroupAnimation)
	}

	
	private func getBoxPoint(i: Int, j: Int, k: Int = 0) -> Box.Point {
		let verticalEdge = self.lengthEdge + self.verticalPadding
		let horisontalEdge = self.lengthEdge + self.horisontalPadding
		let deepEdge = self.lengthEdge + self.deepPadding
		let point = Box.Point(
			x: Float(i) * verticalEdge,
			y: Float(j) * horisontalEdge,
			z: Float(k) * deepEdge
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
