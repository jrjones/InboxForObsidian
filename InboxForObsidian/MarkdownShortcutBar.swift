//
//  MarkdownShortcutBar.swift
//  InboxForObsidian
//
//  Created by Joseph R. Jones on 4/5/25.
//

import SwiftUI

struct MarkdownShortcutBar: View {
    @Binding var draftText: String

    var body: some View {
        HStack {
            Button("**B**") {
                insertMarkdown("**", closing: "**")
            }
            Button("[!]") {
                // Insert a line like "- [!] "
                insertTaskMarker("[!]")
            }
            // Add your other markers, or a Menu
        }
        .buttonStyle(.borderless)
    }

    private func insertMarkdown(_ opening: String, closing: String) {
        draftText += opening + closing
    }

    private func insertTaskMarker(_ marker: String) {
        draftText += "- \(marker) "
    }
}
