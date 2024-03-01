//
//  BoxesWorker.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 25.02.2024.
//

import MFPuzzle
import SceneKit

protocol _StartWorker {
    func crateMatrixBox() -> [SCNNode]
    func calculateCameraPosition(adge: CGFloat) -> SCNVector3
}

/// Занимается созданием и UI настройкой матрицы элементов
final class BoxesWorker: _StartWorker {
	private let grid: Grid
    private let lengthEdge: CGFloat = 4
    private let verticalPadding: CGFloat = 0.4
    private let horisontalPadding: CGFloat = 0.2
    
    private struct Box {
        let x: CGFloat
        let y: CGFloat
        let number: Int
        let lengthEdge: CGFloat
    }
    
    init(grid: Grid) {
        self.grid = grid
    }

    func crateMatrixBox() -> [SCNNode] {
        return createNodesFormMatrix(matrix: self.grid.matrix)
    }
    
    func calculateCameraPosition(adge: CGFloat) -> SCNVector3 {
		let centreX = CGFloat(self.grid.size) * (self.lengthEdge + self.horisontalPadding) - self.horisontalPadding - self.lengthEdge
		let centreY = CGFloat(self.grid.size) * (self.lengthEdge + self.verticalPadding) - self.verticalPadding - self.lengthEdge
		let height = CGFloat(self.grid.size) * (self.lengthEdge + self.horisontalPadding) + CGFloat(self.grid.size) * self.lengthEdge * 0.85
        return SCNVector3(x: Float(centreX / 2), y: Float(-centreY / 2), z: Float(height))
    }
    
    private func createNodesFormMatrix(matrix: Matrix) -> [SCNNode] {
        let verticalEdge = self.lengthEdge + self.verticalPadding
        let horisontalEdge = self.lengthEdge + self.horisontalPadding
        var nodes = [SCNNode]()
        for (i, line) in matrix.enumerated() {
            for (j, number) in line.enumerated() {
                if number == 0 { continue }
                let box = Box(
                    x: CGFloat(i) * verticalEdge,
                    y: CGFloat(j) * horisontalEdge,
                    number: Int(number),
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
        let lengthEdge = box.lengthEdge
        boxNode.geometry = SCNBox(width: lengthEdge, height: lengthEdge, length: lengthEdge, chamferRadius: 1)
		let name = "\(box.number)"
		boxNode.name = name
        //let im = UIImage(systemName: "\(box.number).circle.fill")
        let im = imageWith(name: name)
        
        let material = SCNMaterial()
        // Является базой для поверхности
        material.diffuse.contents = im
        
        // Отвечат за металический отблеск
        material.specular.contents = UIImage(named: "bubble", in: nil, with: nil)
        
        // Отвечает за зеркальный отблеск, в отражени будут обекты, переданные в contents
        //material.reflective.contents = UIImage(named: "bubble", in: nil, with: nil)
        
        // Используется для затемнения или тонирования. Можно использовать как теневую карту
        //material.multiply.contents = im
        
        // Можно имитировать облака
        //material.transparent.contents = UIImage(named: "bubble", in: nil, with: nil)
        //material.ambient.contents =
        
        boxNode.geometry?.firstMaterial = material
        boxNode.position = SCNVector3(box.y, -box.x, 0)
        return boxNode
    }
    
    /// Создание изображения по тексту. Создает текст в круге.
    private func imageWith(name: String?) -> UIImage? {
        let frame = CGRect(x: 25, y: 25, width: 50, height: 50)
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = .blue
        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 30)
        nameLabel.text = name
        nameLabel.layer.cornerRadius = 10
        nameLabel.layer.masksToBounds = true
        let viewFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let view = UIView(frame: viewFrame)
        view.backgroundColor = .red
        view.addSubview(nameLabel)
        UIGraphicsBeginImageContext(viewFrame.size)
        if let currentContext = UIGraphicsGetCurrentContext() {
            view.layer.render(in: currentContext)
            let view = UIGraphicsGetImageFromCurrentImageContext()
            return view
        }
        return nil
    }

}
