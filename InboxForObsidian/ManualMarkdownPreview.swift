import SwiftUI

/// A simple manual Markdown renderer for block-level elements.
/// Supports headings (#, ##, ###), bullet lists (- ), and paragraphs.
struct ManualMarkdownPreview: View {
    let markdown: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(markdown.split(separator: "\n", omittingEmptySubsequences: false)), id: \.self) { rawLine in
                let line = String(rawLine)
                if line.hasPrefix("### ") {
                    Text(line.dropFirst(4))
                        .font(.title3).bold()
                } else if line.hasPrefix("## ") {
                    Text(line.dropFirst(3))
                        .font(.title2).bold()
                } else if line.hasPrefix("# ") {
                    Text(line.dropFirst(2))
                        .font(.title).bold()
                } else if line.hasPrefix("- ") {
                    HStack(alignment: .top, spacing: 4) {
                        Text("•")
                        Text(attributedInline(from: String(line.dropFirst(2))))
                    }
                } else if line.trimmingCharacters(in: .whitespaces).isEmpty {
                    // Blank line: add spacing
                    Spacer().frame(height: 4)
                } else {
                    Text(attributedInline(from: line))
                }
            }
        }
        .textSelection(.enabled)
    }

    /// Parse inline Markdown (bold, italic, links, tasks) for a single line.
    private func attributedInline(from text: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnly)
        return (try? AttributedString(markdown: text, options: options))
            ?? AttributedString(text)
    }
}