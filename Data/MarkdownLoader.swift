//
//  MarkdownLoader.swift
//  Captain Swift
//
//  Created by Oar Gmd on 2026-04-11.
//

import Foundation

struct MarkdownLoader {

    static func load(_ filename: String) -> String {
        guard let url = Bundle.main.url(
            forResource: filename,
            withExtension: "md"
        ) else {
            print("❌ Could not find \(filename).md")
            return "Content coming soon."
        }

        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            print("❌ Could not read \(filename).md")
            return "Content coming soon."
        }

        print("✅ Loaded \(filename).md")
        return content
    }
}
