//
//  Captain_SwiftApp.swift
//  Captain Swift
//
//  Created by Omar Gmd on 2026-04-11.
//

import SwiftUI

@main
struct Captain_SwiftApp: App {
    @State private var highlightStore = HighlightStore()

    @AppStorage("captainswift.readingTheme") private var theme: ReadingTheme = .system

    var body: some Scene {
        WindowGroup {
            ContentView()
                                .environment(highlightStore)
                .preferredColorScheme(theme.colorScheme) // ← NEW: drives the whole app
        }
    }
}
