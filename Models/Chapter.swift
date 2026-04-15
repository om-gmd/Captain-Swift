//
//  Chaptr.swift
//  Captain Swift
//
//  Created by Omar Gmd on 2026-04-11.
//

import Foundation

struct Chapter: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let subtitle: String
    let emoji: String
    let chapterImage: String?
    let sections: [Section]
    let markdownFile: String?
}
