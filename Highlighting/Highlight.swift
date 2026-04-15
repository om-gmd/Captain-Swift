//
//  Highlight.swift
//  Captain Swift
//
//  Created by OMGMD on 2026-04-11.
//

import Foundation

/// A single user-created text highlight within a chapter block.
///
/// Ranges are stored as location + length so they survive NSRange/Codable round-trips.
/// blockIndex is the stable position of the block in the parsed array for a given chapter.
struct Highlight: Codable, Identifiable, Equatable {
    let id: UUID
    let chapterId: Int
    let blockIndex: Int
    let location: Int
    let length: Int
    let colorName: String

    // MARK: - Computed

    var nsRange: NSRange { NSRange(location: location, length: length) }

    var color: HighlightColor {
        HighlightColor(rawValue: colorName) ?? .yellow
    }

    // MARK: - Init

    init(
        id: UUID = UUID(),
        chapterId: Int,
        blockIndex: Int,
        range: NSRange,
        color: HighlightColor
    ) {
        self.id = id
        self.chapterId = chapterId
        self.blockIndex = blockIndex
        self.location = range.location
        self.length = range.length
        self.colorName = color.rawValue
    }
}
