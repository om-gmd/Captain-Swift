//
//  AppFonts.swift
//  Captain Swift
//
//  Created by Omar Gmd  on 2026-04-11.
//

import SwiftUI

extension Font {
    
    // MARK: — Display
    static let heroTitle    = Font.system(size: 34, weight: .bold, design: .rounded)
    static let chapterTitle = Font.system(size: 26, weight: .bold, design: .rounded)
    static let sectionTitle = Font.system(size: 20, weight: .semibold, design: .rounded)
    
    // MARK: — Body
    static let bodyText     = Font.system(size: 17, weight: .regular, design: .default)
    static let captionText  = Font.system(size: 13, weight: .regular, design: .default)
    
    // MARK: — Code
    static let codeFont     = Font.system(size: 14, weight: .regular, design: .monospaced)
    static let codeFontSm   = Font.system(size: 12, weight: .regular, design: .monospaced)
}

// MARK: — Spacing constants
enum Spacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 24
    static let xl:  CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: — Corner radius constants
enum Radius {
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 12
    static let lg:  CGFloat = 20
    static let xl:  CGFloat = 28
}
