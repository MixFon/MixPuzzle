//
//  MMColors.swift
//
//
//  Created by polykuzin on 21/07/2023.
//

import SwiftUI

extension Color {
    
    // MARK: Background colors
    public static var mm_background_primary: Color {
        return Color("mm.background.primary", bundle: .main)
    }
    
    public static var mm_background_secondary: Color {
        return Color("mm.background.secondary", bundle: .main)
    }
    
    public static var mm_background_tertiary: Color {
        return Color("mm.background.tertiary", bundle: .main)
    }
    
    public static var mm_background_tertiary_dark: Color {
        return Color("mm.background.tertiary.dark", bundle: .main)
    }
    
    public static var mm_background_linear_start: Color {
        return Color("mm.backgroundLinear.start", bundle: .main)
    }
    
    public static var mm_background_linear_end: Color {
        return Color("mm.backgroundLinear.end", bundle: .main)
    }
    
    // MARK: Tints
    public static var mm_tint_primary: Color {
        return Color("mm.tint.primary", bundle: .main)
    }
    
    public static var mm_tint_secondary: Color {
        return Color("mm.tint.secondary", bundle: .main)
    }
    
    public static var mm_tint_icons: Color {
        return Color("mm.tint.icons", bundle: .main)
    }
    
    // MARK: Text
    public static var mm_text_primary: Color {
        return Color("mm.text.primary", bundle: .main)
    }
    
    public static var mm_text_secondary: Color {
        return Color("mm.text.secondary", bundle: .main)
    }
    
    public static var mm_text_inverted: Color {
        return Color("mm.text.inverted", bundle: .main)
    }
    
    public static var mm_text_label: Color {
        return Color("mm.text.label", bundle: .main)
    }
    
    // MARK: Dividers
    public static var mm_divider_opaque: Color {
        return Color("mm.divider.opaque", bundle: .main)
    }
    
    public static var mm_divider_non_opaque: Color {
        return Color("mm.divider.nonopaque", bundle: .main)
    }
    
    // MARK: Other
    public static var mm_green: Color {
        return Color("mm.green", bundle: .main)
    }
    
    public static var mm_warning: Color {
        return Color("mm.warning", bundle: .main)
    }
    
    public static var mm_danger: Color {
        return Color("mm.danger", bundle: .main)
    }
    
    // MARK: TextField
    public static var mm_textfield_background: Color {
        return Color("mm.textfield.background", bundle: .main)
    }
    
    // MARK: Buttons
    public static var mm_button_primary: Color {
        return Color("mm.buttonBackground.primary", bundle: .main)
    }
    
    public static var mm_button_inverted: Color {
        return Color("mm.buttonBackground.inverted", bundle: .main)
    }
    
    public static var mm_button_detail_background: Color {
        return Color("mm.button.detail.background", bundle: .main)
    }
}
