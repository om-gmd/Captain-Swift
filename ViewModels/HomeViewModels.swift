//
//  HomeViewModels.swift
//  Captain Swift
//
//  Created by Omar Gmd  on 2026-04-11.
//

import Foundation
import SwiftUI

@Observable
class HomeViewModel {
    var chapters: [Chapter] = []
    var userProgress = UserProgress()
    var isLoading = false

    init() {
        loadChapters()
        loadProgress()
    }

    // MARK: — Load Chapters
    func loadChapters() {
        isLoading = true
        guard let url = Bundle.main.url(forResource: "chapter", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Chapter].self, from: data)
        else {
            print("❌ Failed to load chapters.json")
            isLoading = false
            return
        }
        chapters = decoded
        isLoading = false
        print("✅ Loaded \(chapters.count) chapters")
    }

    // MARK: — Progress Persistence
    func loadProgress() {
        guard let data = UserDefaults.standard.data(forKey: "userProgress"),
              let decoded = try? JSONDecoder().decode(UserProgress.self, from: data)
        else { return }
        userProgress = decoded
    }

    func saveProgress() {
        guard let encoded = try? JSONEncoder().encode(userProgress) else { return }
        UserDefaults.standard.set(encoded, forKey: "userProgress")
    }

    func markCompleted(_ chapterID: Int) {
        userProgress.completedChapterIDs.insert(chapterID)
        saveProgress()
        print("✅ Chapter \(chapterID) marked complete")
    }

    // MARK: — Computed helpers
    var completedCount: Int {
        userProgress.completedChapterIDs.count
    }

    var progressPercentage: Double {
        guard !chapters.isEmpty else { return 0 }
        return Double(completedCount) / Double(chapters.count)
    }
}
