//
//  Ext+Compass.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 02.06.2024.
//

import MFPuzzle
import Foundation

extension Compass {
	
	var imageName: String {
		switch self {
		case .west:
			//return "arrowshape.right.fill"
			return "arrow.right"
		case .east:
			//return "arrowshape.left.fill"
			return "arrow.left"
		case .north:
			//return "arrowshape.up.fill"
			return "arrow.up"
		case .south:
			//return "arrowshape.down.fill"
			return "arrow.down"
		case .needle:
			return "square.grid.3x3.fill"
		}
	}
}
