//
//  SidebarView.swift
//  Captain Swift
//
//  Created by Omar Gmd on 2026-04-11.
//

import SwiftUI

struct SidebarView: View {

    @State private var viewModel = HomeViewModel()
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                progressSection
                chapterGrid
            }
        }
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: — Header
    private var headerSection: some View {
        Image("home_hero")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
    }

    // MARK: — Progress Bar
    private var progressSection: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Your Progress")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(viewModel.completedCount) / \(viewModel.chapters.count) chapters")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemFill))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color.captainOrange, Color.captainPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geo.size.width * viewModel.progressPercentage,
                            height: 8
                        )
                        .animation(.spring(response: 0.5), value: viewModel.progressPercentage)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    // MARK: — Chapter Grid
    private var chapterGrid: some View {
        let columns = sizeClass == .regular
            ? [GridItem(.flexible()), GridItem(.flexible())]
            : [GridItem(.flexible())]

        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(viewModel.chapters) { chapter in
                let isCompleted = viewModel.userProgress.isCompleted(chapter.id)
                NavigationLink(value: chapter) {
                    ChapterCard(chapter: chapter, isCompleted: isCompleted)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .navigationDestination(for: Chapter.self) { chapter in
            ChapterView(
                chapter: chapter,
                onComplete: { viewModel.markCompleted(chapter.id) }
            )
        }
    }
}
