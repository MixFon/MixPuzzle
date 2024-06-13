//
//  FileManage.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 05.05.2024.
//

import Foundation

protocol _Keeper {
	func saveString(string: String, fileName: String)
	func readString(fileName: String) -> String?
}

final class FileWorker: _Keeper {
	
	/// Функция для сохранения строки в файл
	func saveString(string: String, fileName: String) {
		guard let fileURL = getFileURL(fileName: fileName) else { return }
		
		do {
			try string.write(to: fileURL, atomically: true, encoding: .utf8)
			print("Строка успешно сохранена в файл: \(fileName)")
		} catch {
			print("Ошибка при сохранении строки в файл: \(fileName), \(error)")
		}
	}
	
	/// Функция для чтения строки из файла
	func readString(fileName: String) -> String? {
		guard let fileURL = getFileURL(fileName: fileName) else { return nil }
		
		do {
			let string = try String(contentsOf: fileURL, encoding: .utf8)
			return string
		} catch {
			print("Ошибка при чтении строки из файла: \(error.localizedDescription)")
			return nil
		}
	}
	
	/// Вспомогательная функция для получения URL файла
	private func getFileURL(fileName: String) -> URL? {
		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
		let fileURL = documentsDirectory?.appendingPathComponent(fileName)
		return fileURL
	}
}

final class MockFileWorker: _Keeper {
	func saveString(string: String, fileName: String) {
		print(#function)
	}
	
	func readString(fileName: String) -> String? {
		return """
4
1 2 3 4
5 6 7 8
9 10 11 12
13 14 15 0
"""
	}
}
