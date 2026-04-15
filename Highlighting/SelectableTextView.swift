//
//  SelectableTextView.swift
//  Captain Swift
//
//  Created by OMGMD on 2026-04-11.
//

import SwiftUI
import UIKit

// MARK: - UITextView Subclass
final class HighlightableTextView: UITextView {

    var onHighlight: ((NSRange, HighlightColor) -> Void)?
    var onRemoveHighlight: ((NSRange) -> Void)?

    // MARK: - Setup

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        isEditable                        = false
        isSelectable                      = true
        isScrollEnabled                   = false   // outer SwiftUI ScrollView handles this
        backgroundColor                   = .clear
        textContainerInset                = .zero   // no extra padding
        textContainer.lineFragmentPadding = 0
        dataDetectorTypes                 = []
    }

    // MARK: - Custom Edit Menu (iOS 16+)

    override func buildMenu(with builder: any UIMenuBuilder) {
        super.buildMenu(with: builder)

        // Strip menus that don't belong in a reading app
        builder.remove(menu: .lookup)
        builder.remove(menu: .learn)
        builder.remove(menu: .share)
        builder.remove(menu: .format)

        let selection = selectedRange

        if selection.length == 0 {
            // No selection — check if the cursor is sitting inside a highlight
            if let existingRange = highlightedRange(containingCharacterAt: selection.location) {
                let removeAction = UIAction(
                    title: "Remove Highlight",
                    image: UIImage(systemName: "xmark.circle"),
                    attributes: .destructive
                ) { [weak self] _ in
                    self?.onRemoveHighlight?(existingRange)
                }
                builder.insertSibling(
                    UIMenu(options: .displayInline, children: [removeAction]),
                    afterMenu: .standardEdit
                )
            }
            return
        }

        // Text is selected — build the six color actions
        let colorActions: [UIAction] = HighlightColor.allCases.map { [weak self] color in
            UIAction(
                title: color.displayName,
                image: color.swatchImage().withRenderingMode(.alwaysOriginal)
            ) { _ in
                self?.onHighlight?(selection, color)
                // Collapse the selection after applying so the menu dismisses cleanly
                DispatchQueue.main.async {
                    self?.selectedRange = NSRange(
                        location: selection.location + selection.length,
                        length: 0
                    )
                }
            }
        }

        let highlightMenu = UIMenu(
            title: "Highlight",
            image: UIImage(systemName: "highlighter"),
            options: .displayInline,
            children: colorActions
        )
        builder.insertSibling(highlightMenu, afterMenu: .standardEdit)
    }

    // MARK: - Helpers
    private func highlightedRange(containingCharacterAt position: Int) -> NSRange? {
        guard let text = attributedText, text.length > 0 else { return nil }
        var found: NSRange?
        text.enumerateAttribute(
            .backgroundColor,
            in: NSRange(location: 0, length: text.length)
        ) { value, range, stop in
            guard value != nil, NSLocationInRange(position, range) else { return }
            found = range
            stop.pointee = true
        }
        return found
    }

    override var canBecomeFirstResponder: Bool { true }
}

// MARK: - UIViewRepresentable
struct SelectableTextView: UIViewRepresentable {

    let text: String
    let font: UIFont
    let textColor: UIColor
    let lineSpacing: CGFloat
    let chapterId: Int
    let blockIndex: Int

    @Bindable var store: HighlightStore

    // MARK: - UIViewRepresentable

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIView(context: Context) -> HighlightableTextView {
        let view = HighlightableTextView()
        view.delegate = context.coordinator
        view.onHighlight = { range, color in
            context.coordinator.apply(range: range, color: color)
        }
        view.onRemoveHighlight = { range in
            context.coordinator.removeHighlight(at: range)
        }
        refreshContent(in: view)
        return view
    }

    func updateUIView(_ view: HighlightableTextView, context: Context) {
        refreshContent(in: view)
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: HighlightableTextView,
        context: Context
    ) -> CGSize? {
        let width = proposal.width ?? 390
        let fitsSize = uiView.sizeThatFits(
            CGSize(width: width, height: .greatestFiniteMagnitude)
        )
        return CGSize(width: width, height: max(fitsSize.height, 1))
    }

    // MARK: - Private

    private func refreshContent(in view: HighlightableTextView) {
        let currentHighlights = store.highlights(for: chapterId, blockIndex: blockIndex)
        view.attributedText = buildAttributedString(highlights: currentHighlights)
    }
    
    private func buildAttributedString(highlights: [Highlight]) -> NSAttributedString {
        // Parse inline markdown via AttributedString first
        let parsed = (try? AttributedString(
            markdown: text,
            options: AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .inlineOnlyPreservingWhitespace
            )
        )) ?? AttributedString(text)

        let nsAttr = NSMutableAttributedString(parsed)
        let fullRange = NSRange(location: 0, length: nsAttr.length)

        // Build paragraph style
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = lineSpacing

    
        nsAttr.enumerateAttributes(in: fullRange) { attrs, range, _ in
            var resolvedFont = font
            if let existing = attrs[.font] as? UIFont {
                let traits = existing.fontDescriptor.symbolicTraits
                if traits.contains(.traitBold),
                   let boldDescriptor = font.fontDescriptor.withSymbolicTraits(.traitBold) {
                    resolvedFont = UIFont(descriptor: boldDescriptor, size: font.pointSize)
                }
            }
            nsAttr.addAttribute(.font, value: resolvedFont, range: range)
        }

        nsAttr.addAttribute(.foregroundColor, value: textColor, range: fullRange)
        nsAttr.addAttribute(.paragraphStyle, value: paraStyle, range: fullRange)

        // Apply highlight background colors on top
        for highlight in highlights {
            let r = highlight.nsRange
            guard r.location != NSNotFound,
                  r.location + r.length <= nsAttr.length else { continue }
            nsAttr.addAttribute(
                .backgroundColor,
                value: highlight.color.uiColor.withAlphaComponent(HighlightColor.highlightAlpha),
                range: r
            )
        }

        return nsAttr
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, UITextViewDelegate {
        let parent: SelectableTextView

        init(parent: SelectableTextView) { self.parent = parent }

        func apply(range: NSRange, color: HighlightColor) {
            parent.store.add(
                chapterId: parent.chapterId,
                blockIndex: parent.blockIndex,
                range: range,
                color: color
            )
        }

        func removeHighlight(at range: NSRange) {
            parent.store.removeHighlight(
                touching: range,
                chapterId: parent.chapterId,
                blockIndex: parent.blockIndex
            )
        }
    }
}
