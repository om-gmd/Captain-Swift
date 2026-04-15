//
//  HighlightColor.swift
//  Captain Swift
//
//  Created by Omar Gmd on 2026-04-11.
//

import SwiftUI
import UIKit

/// The six highlight colors Apple Notes uses, with exact hex values from the system palette.
enum HighlightColor: String, CaseIterable, Codable, Identifiable {
    case yellow
    case green
    case pink
    case purple
    case blue
    case orange

    var id: String { rawValue }

    // MARK: - Apple Notes exact colors

    var swiftUIColor: Color {
        switch self {
        case .yellow: return Color(hex: "FFD60A")
        case .green:  return Color(hex: "30D158")
        case .pink:   return Color(hex: "FF375F")
        case .purple: return Color(hex: "BF5AF2")
        case .blue:   return Color(hex: "0A84FF")
        case .orange: return Color(hex: "FF9F0A")
        }
    }

    var uiColor: UIColor { UIColor(swiftUIColor) }

    /// Alpha applied to the background when rendering a highlight.
    static let highlightAlpha: CGFloat = 0.38

    var displayName: String { rawValue.capitalized }

    /// Filled circle image used in the context menu color picker.
    func swatchImage(diameter: CGFloat = 20) -> UIImage {
        let size = CGSize(width: diameter, height: diameter)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            uiColor.setFill()
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
        }
    }
}
