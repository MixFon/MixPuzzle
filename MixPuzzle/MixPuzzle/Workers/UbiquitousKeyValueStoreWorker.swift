//
//  UbiquitousKeyValueStoreWorker.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 23.08.2025.
//

import Foundation

final class UbiquitousKeyValueStoreWorker: _Keeper {
	
	private let defaults = NSUbiquitousKeyValueStore.default
	
	func saveString(string: String, fileName: String) {
		self.defaults.set(string, forKey: fileName)
	}
	
	func readString(fileName: String) -> String? {
		self.defaults.string(forKey: fileName)
	}
}
