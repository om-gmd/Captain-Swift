//
//  ChapterView.swift
//  Captain Swift
//
//  Created by Omar Gmd  on 2026-04-11.
//

import SwiftUI

struct ChapterView: View {
    let chapter: Chapter
    let onComplete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(HighlightStore.self) private var highlightStore  // NEW
    
    // Same key as the app root — @AppStorage keeps them in sync for free.
        @AppStorage("captainswift.readingTheme") private var theme: ReadingTheme = .system

    @State private var markdownContent: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroHeader
                if !markdownContent.isEmpty {
                    MarkdownContentView(
                        content: markdownContent,
                        chapterId: chapter.id,
                        store: highlightStore            // NEW
                    )
                    .padding(20)
                } else {
                    VStack(alignment: .leading, spacing: 32) {
                        ForEach(Array(chapter.sections.enumerated()), id: \.element.id) { index, section in
                            SectionBlock(
                                section: section,
                                chapterId: chapter.id,
                                blockIndex: index,       // NEW
                                store: highlightStore    // NEW
                            )
                        }
                    }
                    .padding(20)
                }
            }
            .frame(maxWidth: 720)
                   .frame(maxWidth: .infinity)
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                themeMenu  // ← ADD THIS
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    onComplete()
                    dismiss()
                } label: {
                    Label("Complete", systemImage: "checkmark.circle")
                        .foregroundStyle(Color.captainGreen)
                }
            }
        }
        .task(id: chapter.id) {
            markdownContent = ""
            if let file = chapter.markdownFile {
                markdownContent = MarkdownLoader.load(file)
            }
        }
    }

    // MARK: - Theme Menu

        /// A toolbar button that cycles System → Light → Dark.
        /// Shows the current mode's icon; tapping opens a menu with all three options.
        private var themeMenu: some View {
            Menu {
                ForEach(ReadingTheme.allCases, id: \.self) { option in
                    Button {
                        theme = option
                    } label: {
                        Label(option.label, systemImage: option.icon)
                        // Checkmark on the active choice
                        if theme == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            } label: {
                Image(systemName: theme.icon)
                    .foregroundStyle(Color.captainPurple)
            }
        }
    // MARK: - Hero Header (unchanged)

    private var heroHeader: some View {
        Image("chapter\(chapter.id)_hero")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
    }
}

// MARK: - Markdown Content Renderer

struct MarkdownContentView: View {
    let content: String
    let chapterId: Int
    @Bindable var store: HighlightStore

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // enumerated() gives us the stable blockIndex
            ForEach(Array(parseBlocks(content).enumerated()), id: \.element.id) { index, block in
                BlockView(
                    block: block,
                    chapterId: chapterId,
                    blockIndex: index,
                    store: store
                )
            }
        }
    }

    func parseBlocks(_ text: String) -> [ContentBlock] {
        var blocks: [ContentBlock] = []
        let lines = text.components(separatedBy: "\n")
        var i = 0

        while i < lines.count {
            let line = lines[i]

            // Code block
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                var codeLines: [String] = []
                i += 1
                while i < lines.count &&
                      !lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                    codeLines.append(lines[i])
                    i += 1
                }
                blocks.append(ContentBlock(type: .code, text: codeLines.joined(separator: "\n")))
                i += 1
                continue
            }

            // Challenge / tip block
            if line.hasPrefix(">") {
                var challengeLines: [String] = []
                while i < lines.count && lines[i].hasPrefix(">") {
                    let cleaned = lines[i]
                        .trimmingCharacters(in: .whitespaces)
                        .replacingOccurrences(of: "> ⚡ **Mini Challenge", with: "")
                        .replacingOccurrences(of: "> 🦸 **Superhero Tip", with: "")
                        .replacingOccurrences(of: "> ⚡", with: "")
                        .replacingOccurrences(of: "> 🦸", with: "")
                        .replacingOccurrences(of: "> ", with: "")
                        .replacingOccurrences(of: ">", with: "")
                        .replacingOccurrences(of: "**", with: "")
                        .trimmingCharacters(in: .whitespaces)
                    if !cleaned.isEmpty &&
                       !cleaned.hasPrefix("Mini Challenge:") &&
                       !cleaned.hasPrefix("Superhero Tip:") {
                        challengeLines.append(cleaned)
                    }
                    i += 1
                }
                if !challengeLines.isEmpty {
                    blocks.append(ContentBlock(type: .challenge, text: challengeLines.joined(separator: "\n")))
                }
                continue
            }

            if line.hasPrefix("# ")   { blocks.append(ContentBlock(type: .h1, text: String(line.dropFirst(2)))); i += 1; continue }
            if line.hasPrefix("## ")  { blocks.append(ContentBlock(type: .h2, text: String(line.dropFirst(3)))); i += 1; continue }
            if line.hasPrefix("### ") { blocks.append(ContentBlock(type: .h3, text: String(line.dropFirst(4)))); i += 1; continue }

            if line.hasPrefix("---") {
                blocks.append(ContentBlock(type: .divider, text: ""))
                i += 1
                continue
            }

            if line.trimmingCharacters(in: .whitespaces).isEmpty { i += 1; continue }

            // Bullet list — collected into one block so highlights span across items
            if line.hasPrefix("- ") || line.hasPrefix("* ") {
                var bulletLines: [String] = []
                while i < lines.count && (lines[i].hasPrefix("- ") || lines[i].hasPrefix("* ")) {
                    bulletLines.append("• " + String(lines[i].dropFirst(2)))
                    i += 1
                }
                blocks.append(ContentBlock(type: .bullets, text: bulletLines.joined(separator: "\n")))
                continue
            }

            // Regular paragraph
            var paraLines: [String] = []
            while i < lines.count &&
                  !lines[i].trimmingCharacters(in: .whitespaces).isEmpty &&
                  !lines[i].hasPrefix("#") &&
                  !lines[i].hasPrefix("```") &&
                  !lines[i].hasPrefix(">") &&
                  !lines[i].hasPrefix("---") &&
                  !lines[i].hasPrefix("- ") {
                paraLines.append(lines[i])
                i += 1
            }
            if !paraLines.isEmpty {
                blocks.append(ContentBlock(type: .paragraph, text: paraLines.joined(separator: " ")))
            }
        }

        return blocks
    }
}

// MARK: - Content Block Model (unchanged)

struct ContentBlock: Identifiable {
    let id = UUID()
    let type: BlockType
    let text: String

    enum BlockType {
        case h1, h2, h3, paragraph, code, challenge, bullets, divider
    }
}

// MARK: - Block View

struct BlockView: View {
    let block: ContentBlock
    let chapterId: Int
    let blockIndex: Int
    @Bindable var store: HighlightStore

    var body: some View {
        switch block.type {

        // Headings — selectable and highlightable
        case .h1:
            SelectableTextView(
                text: block.text,
                font: .systemFont(ofSize: 28, weight: .bold),
                textColor: UIColor.label,
                lineSpacing: 2,
                chapterId: chapterId,
                blockIndex: blockIndex,
                store: store
            )
            .padding(.top, 8)

        case .h2:
            SelectableTextView(
                text: block.text,
                font: .systemFont(ofSize: 20, weight: .bold),
                textColor: UIColor.label,
                lineSpacing: 2,
                chapterId: chapterId,
                blockIndex: blockIndex,
                store: store
            )
            .padding(.top, 4)

        case .h3:
            SelectableTextView(
                text: block.text,
                font: .systemFont(ofSize: 17, weight: .semibold),
                textColor: UIColor(Color.captainPurple),
                lineSpacing: 2,
                chapterId: chapterId,
                blockIndex: blockIndex,
                store: store
            )

        // Body copy — selectable and highlightable
        case .paragraph:
            SelectableTextView(
                text: block.text,
                font: .systemFont(ofSize: 17),
                textColor: UIColor.secondaryLabel,
                lineSpacing: 5,
                chapterId: chapterId,
                blockIndex: blockIndex,
                store: store
            )

        // Bullets as a single selectable block
        case .bullets:
            SelectableTextView(
                text: block.text,
                font: .systemFont(ofSize: 17),
                textColor: UIColor.secondaryLabel,
                lineSpacing: 6,
                chapterId: chapterId,
                blockIndex: blockIndex,
                store: store
            )

        // Non-selectable blocks — unchanged from before
        case .code:
            CodeBlock(code: block.text)

        case .challenge:
            ChallengeBlock(text: block.text)

        case .divider:
            Divider().padding(.vertical, 8)
        }
    }
}

// MARK: - Section Block (JSON-driven chapters)

struct SectionBlock: View {
    let section: Section
    let chapterId: Int
    let blockIndex: Int
    @Bindable var store: HighlightStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SelectableTextView(
                text: section.heading,
                font: .systemFont(ofSize: 20, weight: .semibold),
                textColor: UIColor.label,
                lineSpacing: 2,
                chapterId: chapterId,
                blockIndex: blockIndex * 10,        // *10 so heading and body don't share an index
                store: store
            )
            SelectableTextView(
                text: section.body,
                font: .systemFont(ofSize: 17),
                textColor: UIColor.secondaryLabel,
                lineSpacing: 4,
                chapterId: chapterId,
                blockIndex: blockIndex * 10 + 1,
                store: store
            )
            if let code = section.codeSnippet {
                CodeBlock(code: code)
            }
            if let challenge = section.challenge {
                ChallengeBlock(text: challenge)
            }
        }
    }
}

// MARK: - Code Block (unchanged)

struct CodeBlock: View {
    let code: String
    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 6) {
                    Circle().fill(Color(hex: "FF5F57")).frame(width: 10, height: 10)
                    Circle().fill(Color(hex: "FFBD2E")).frame(width: 10, height: 10)
                    Circle().fill(Color(hex: "28CA41")).frame(width: 10, height: 10)
                }
                Spacer()
                Button {
                    UIPasteboard.general.string = code
                    copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copied = false }
                } label: {
                    Label(copied ? "Copied!" : "Copy",
                          systemImage: copied ? "checkmark" : "doc.on.doc")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(copied ? .green : .secondary)
                }
                .animation(.easeInOut(duration: 0.2), value: copied)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(hex: "2A2A3E"))

            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(.codeFont)
                    .foregroundStyle(Color.codeForeground)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.codeBackground)
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }
}

// MARK: - Challenge Block (unchanged)

struct ChallengeBlock: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("⚡").font(.title3)
            VStack(alignment: .leading, spacing: 6) {
                Text("Mini Challenge")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
            }
        }
        .padding(16)
        .background(Color.orange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ChapterView(
            chapter: Chapter(
                id: 1,
                title: "Welcome to iOS Superhero Academy",
                subtitle: "Your origin story begins here",
                emoji: "🦸",
                chapterImage: nil,
                sections: [],
                markdownFile: nil
            ),
            onComplete: {}
        )
        .environment(HighlightStore())
    }
}
