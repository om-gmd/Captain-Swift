//
//  Section.swift
//  Captain Swift
//
//  Created by Omar Gmd on 2026-04-11.
//

import Foundation

struct Section: Identifiable, Codable, Hashable {
    let id: String
    let heading: String
    let body: String
    let codeSnippet: String?
    let challenge: String?
    let markdownFile: String? 
}
