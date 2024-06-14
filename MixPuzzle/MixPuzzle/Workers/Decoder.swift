//
//  Decoder.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 14.06.2024.
//

import Foundation
protocol _Decoder {
	func encode<T: Encodable>(_ value: T) -> String?
	func decode<T: Decodable>(_ type: T.Type, from string: String) -> T?
}

final class Decoder: _Decoder {
	
	func encode<T: Encodable>(_ value: T) -> String? {
		let encoder = JSONEncoder()
		guard let data = try? encoder.encode(value) else { return nil }
		return String(data: data, encoding: .utf8)
	}

	func decode<T: Decodable>(_ type: T.Type, from string: String) -> T? {
		let decoder = JSONDecoder()
		guard let data = string.data(using: .utf8) else { return nil }
		return try? decoder.decode(T.self, from: data)
	}
}
