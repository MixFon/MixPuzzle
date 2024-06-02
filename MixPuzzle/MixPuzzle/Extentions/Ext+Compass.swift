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
			return "arrowshape.forward.fill"
		case .east:
			return "arrowshape.backward.fill"
		case .north:
			return "arrowshape.up.fill"
		case .south:
			return "arrowshape.down.fill"
		}
	}
}
