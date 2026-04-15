//
//  UserProgress.swift
//  Captain Swift
//
//  Created by Omar Gmd  on 2026-04-11.
//

import Foundation

struct UserProgress: Codable {
    var completedChapterIDs: Set<Int> = []

    func isCompleted(_ chapterID: Int) -> Bool {
        completedChapterIDs.contains(chapterID)
    }
}
