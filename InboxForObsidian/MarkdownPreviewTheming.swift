//
//  Foo.swift
//  InboxForObsidian
//
//  Created by Joseph R. Jones on 4/27/25.
//

import MarkdownUI

// MARK: - MarkdownUI Minimal Obsidian Theme
public extension Theme {
    /// A minimal Obsidian-inspired MarkdownUI theme with transparent background,
    /// dynamic primary text color, and minimal padding.
    static let obsidianMinimal: Theme = Theme()
        // Headings: semibold and descending sizes
        .heading1 { config in
            config.label
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .heading2 { config in
            config.label
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .heading3 { config in
            config.label
                .font(.title3)
                .foregroundColor(.primary)
        }
        .heading4 { config in
            config.label
                .font(.headline)
                .foregroundColor(.primary)
        }
        .heading5 { config in
            config.label
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .heading6 { config in
            config.label
                .font(.footnote)
                .foregroundColor(.primary)
        }
        // Paragraphs and list items use body font
        .paragraph { config in
            config.label
                .font(.body)
                .foregroundColor(.primary)
        }
        .listItem { config in
            config.label
                .font(.body)
                .foregroundColor(.primary)
        }
}
