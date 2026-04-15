//
//  HomeView.swift
//  Captain Swift
//
//  Created by Omar Gmd  on 2026-04-11.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                    progressSection
                    chapterList
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
        }
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
        // removed: .background(Color(.systemBackground))
        // removed: .padding(.bottom, 8)
    }

    // MARK: — Chapter List
    private var chapterList: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.chapters) { chapter in
                let isCompleted = viewModel.userProgress.isCompleted(chapter.id)
                NavigationLink(destination: ChapterView(
                    chapter: chapter,
                    onComplete: { viewModel.markCompleted(chapter.id) }
                )) {
                    ChapterCard(chapter: chapter, isCompleted: isCompleted)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
    }
}

// ChapterCard 
struct ChapterCard: View {
    let chapter: Chapter
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 16) {
            Group {
                if let imageName = chapter.chapterImage,
                   UIImage(named: imageName) != nil {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    Text(chapter.emoji)
                        .font(.system(size: 36))
                        .frame(width: 64, height: 64)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Chapter \(chapter.id)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Text(chapter.title)
                    .font(.headline)
                    .lineLimit(2)
                Text(chapter.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.captainGreen)
                    .font(.system(size: 16, weight: .semibold))
            } else {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 16, weight: .semibold))
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    HomeView()
       
}
