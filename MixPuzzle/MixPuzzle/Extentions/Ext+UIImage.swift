//
//  Ext+UIImage.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 29.12.2024.
//

import UIKit

extension UIImage {
	
	static var mix_icon_close: UIImage {
		return UIImage(named: "mix.icon.close", in: Bundle.main, with: nil) ?? .add
	}
	
	static var mix_icon_help: UIImage {
		return UIImage(named: "mix.icon.help", in: Bundle.main, with: nil) ?? .add
	}
	
	static var mix_icon_menu: UIImage {
		return UIImage(named: "mix.icon.menu", in: Bundle.main, with: nil) ?? .add
	}
	
	static var mix_icon_restart: UIImage {
		return UIImage(named: "mix.icon.restart", in: Bundle.main, with: nil) ?? .add
	}
	
	static var mix_icon_updates: UIImage {
		return UIImage(named: "mix.icon.updates", in: Bundle.main, with: nil) ?? .add
	}
}
