//
//  StartState.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 07.12.2024.
//

enum StartState {
	/// Состояние игры. Ввержу 3 кнопки
	case game
	/// Состояние меню. Вверху только назад и показано меню.
	case menu
	/// Показ решения. Вниду компас. Вверху назад и флаг
	case solution
}
