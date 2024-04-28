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
    func imageWith(configuration: ConfigurationImage) -> UIImage?
}

struct ConfigurationImage {
    let size: Double
    let radius: Double
    var textImage: String
    let colorLable: UIColor
    let nameImageTexture: String
}

final class ImageWorker: _ImageWorker {
	
	/// Создание изображения по тексту. Создает текст в круге.
    func imageWith(configuration: ConfigurationImage) -> UIImage? {
        let size = configuration.size
        let sizeFrame = 400.0
		let frame = CGRect(x: (sizeFrame - size) / 2, y: (sizeFrame - size) / 2, width: size, height: size)
		let nameLabel = UILabel(frame: frame)
		nameLabel.textAlignment = .center
        nameLabel.backgroundColor = configuration.colorLable
		nameLabel.textColor = .white
		nameLabel.font = UIFont.boldSystemFont(ofSize: 100)
        nameLabel.text = configuration.textImage
        nameLabel.layer.cornerRadius = configuration.radius
		nameLabel.layer.masksToBounds = true
		let viewFrame = CGRect(x: 0, y: 0, width: sizeFrame, height: sizeFrame)
        let imageView = UIImageView(frame: viewFrame)
        imageView.image = UIImage(named: configuration.nameImageTexture, in: nil, with: nil)
        imageView.addSubview(nameLabel)
		UIGraphicsBeginImageContext(viewFrame.size)
		if let currentContext = UIGraphicsGetCurrentContext() {
            imageView.layer.render(in: currentContext)
			let view = UIGraphicsGetImageFromCurrentImageContext()
			return view
		}
		return nil
	}
}
