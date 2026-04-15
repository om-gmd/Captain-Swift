//
//  HighlightStore.swift
//  Captain Swift
//
//  Created by OMGMD on 2026-04-11.
//

import Foundation
import Observation

/// The single source of truth for all user highlights.
///
/// Persists to UserDefaults. Injected into the SwiftUI environment at the app root
/// so every view in the hierarchy can read/write it without prop-drilling.
@Observable
final class HighlightStore {

    // MARK: - State

    private(set) var highlights: [Highlight] = []

    // MARK: - Private

    private let storageKey = "captainswift.highlights.v1"

    // MARK: - Init

    init() { load() }

    // MARK: - Queries

    func highlights(for chapterId: Int, blockIndex: Int) -> [Highlight] {
        highlights.filter {
            $0.chapterId == chapterId && $0.blockIndex == blockIndex
        }
    }

    func hasHighlights(in chapterId: Int) -> Bool {
        highlights.contains { $0.chapterId == chapterId }
    }

    // MARK: - Mutations

    func add(chapterId: Int, blockIndex: Int, range: NSRange, color: HighlightColor) {
        // Remove any existing highlights that overlap the new range
        removeOverlapping(chapterId: chapterId, blockIndex: blockIndex, range: range)

        let highlight = Highlight(
            chapterId: chapterId,
            blockIndex: blockIndex,
            range: range,
            color: color
        )
        highlights.append(highlight)
        persist()
    }

    func remove(id: UUID) {
        highlights.removeAll { $0.id == id }
        persist()
    }

    func removeHighlight(touching range: NSRange, chapterId: Int, blockIndex: Int) {
        highlights.removeAll { h in
            h.chapterId == chapterId &&
            h.blockIndex == blockIndex &&
            NSIntersectionRange(h.nsRange, range).length > 0
        }
        persist()
    }

    func removeAll(in chapterId: Int) {
        highlights.removeAll { $0.chapterId == chapterId }
        persist()
    }

    // MARK: - Private helpers

    private func removeOverlapping(chapterId: Int, blockIndex: Int, range: NSRange) {
        highlights.removeAll { h in
            h.chapterId == chapterId &&
            h.blockIndex == blockIndex &&
            NSIntersectionRange(h.nsRange, range).length > 0
        }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(highlights) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([Highlight].self, from: data)
        else { return }
        highlights = decoded
    }
}
