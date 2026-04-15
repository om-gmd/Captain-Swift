//
//  ReadingTheme.swift
//  Captain Swift
//
//  Created by OMGMD on 2026-04-11.
//

import SwiftUI

/// The three appearance options shown in the reading toolbar.
/// Stored as a String so @AppStorage can persist it directly.
enum ReadingTheme: String, CaseIterable {
    case system
    case light
    case dark

    /// Returning nil for .system tells SwiftUI to follow the device setting.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    var label: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max"
        case .dark:   return "moon.stars"
        }
    }
}
