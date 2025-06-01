//
//  Ext+Solution.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 23.03.2025.
//

import MFPuzzle

extension Solution {
	
	var name: String {
		switch self {
		case .snail:
			return String(localized: "Snail", comment: "Name snain solution")
		case .classic:
			return String(localized: "Classic", comment: "Name classic solution")
		case .boustrophedon:
			return String(localized: "Boustrophedon", comment: "Name boustrophedon solution")
		}
	}
}

extension Solution: @retroactive CaseIterable {
	public static let allCases: [Solution] = [.snail, .classic, .boustrophedon]
}

extension Solution: @retroactive CustomStringConvertible {
	public var description: String {
		return name
	}
}
