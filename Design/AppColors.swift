//
//  AppColors.swift
//  Captain Swift
//
//  Created by Omar Gmd  on 2026-04-11.
//

import SwiftUI

extension Color {
    
    // MARK: — Brand Colors
    static let captainOrange    = Color(hex: "FF6B35")
    static let captainGold      = Color(hex: "FFB800")
    static let captainPurple    = Color(hex: "6C5CE7")
    static let captainBlue      = Color(hex: "0984E3")
    static let captainGreen     = Color(hex: "00B894")
    
    // MARK: — Semantic Colors
    static let heroBackground   = Color(hex: "F8F9FA")
    static let cardBackground   = Color.white
    static let codeBackground   = Color(hex: "1E1E2E")
    static let codeForeground   = Color(hex: "CDD6F4")
    
    // MARK: — Hex initialiser
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
