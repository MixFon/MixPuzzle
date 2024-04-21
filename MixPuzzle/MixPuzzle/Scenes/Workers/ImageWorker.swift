//
//  ImageWorker.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 14.04.2024.
//

import UIKit
import SwiftUI
import Foundation

protocol _ImageWorker {
	/// Создание изображения по тексту
	func imageWith(textImage: String) -> UIImage?

	
	/// Создание изображения по тексту
    func imageWith(textImage: String, radius: Double, size: Double, lableColor: UIColor, backgroundColor: UIColor) -> UIImage?
}


final class ImageWorker: _ImageWorker {
	
	/// Создание изображения по тексту. Создает текст в круге.
	func imageWith(textImage: String) -> UIImage? {
		let frame = CGRect(x: 25, y: 25, width: 50, height: 50)
		let nameLabel = UILabel(frame: frame)
		nameLabel.textAlignment = .center
		nameLabel.backgroundColor = .blue
		nameLabel.textColor = .white
		nameLabel.font = UIFont.boldSystemFont(ofSize: 30)
		nameLabel.text = textImage
		nameLabel.layer.cornerRadius = 20
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
	
	/// Создание изображения по тексту. Создает текст в круге.
    func imageWith(textImage: String, radius: Double, size: Double, lableColor: UIColor, backgroundColor: UIColor) -> UIImage? {
		let frame = CGRect(x: (100 - size) / 2, y: (100 - size) / 2, width: size, height: size)
		let nameLabel = UILabel(frame: frame)
		nameLabel.textAlignment = .center
		nameLabel.backgroundColor = lableColor
		nameLabel.textColor = .white
		nameLabel.font = UIFont.boldSystemFont(ofSize: 30)
		nameLabel.text = textImage
		nameLabel.layer.cornerRadius = radius
		nameLabel.layer.masksToBounds = true
		let viewFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
		let view = UIView(frame: viewFrame)
		view.backgroundColor = backgroundColor
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
