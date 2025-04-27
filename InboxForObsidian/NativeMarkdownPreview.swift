import SwiftUI

/// A native SwiftUI Markdown preview using AttributedString(markdown:) with full syntax support.
struct NativeMarkdownPreview: View {
    let markdown: String

    private var attributed: AttributedString {
        // Enable full Markdown syntax: headings, lists, tasks, code blocks, etc.
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)
        return (try? AttributedString(markdown: markdown, options: options))
            ?? AttributedString(markdown)
    }

    var body: some View {
        ScrollView {
            Text(attributed)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }
}

