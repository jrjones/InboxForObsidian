import SwiftUI
import Foundation

/// A Markdown preview that replaces task markers ([ ]) with SF Symbols,
/// without modifying the underlying markdown text.
struct TaskMarkdownPreview: View {
    /// Raw markdown text to preview.
    let markdown: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(lines.indices, id: \.self) { idx in
                lineView(for: lines[idx])
            }
        }
        .textSelection(.enabled)
    }

    /// Split markdown into lines, preserving empty lines.
    private var lines: [String] {
        markdown.split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init)
    }

    @ViewBuilder
    private func lineView(for rawLine: String) -> some View {
        let line = rawLine
        if let (status, content) = parseTask(line) {
            // Task line: show SF Symbol instead of marker
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: status.symbol ?? status.fallbackSymbol)
                    .foregroundColor(tintColor(for: status))
                Text(attributedInline(from: content))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else if line.hasPrefix("### ") {
            Text(line.dropFirst(4))
                .font(.title3).bold()
        } else if line.hasPrefix("## ") {
            Text(line.dropFirst(3))
                .font(.title2).bold()
        } else if line.hasPrefix("# ") {
            Text(line.dropFirst(2))
                .font(.title).bold()
        } else if line.hasPrefix("- ") {
            // Standard bullet
            HStack(alignment: .top, spacing: 4) {
                Text("•")
                Text(attributedInline(from: String(line.dropFirst(2))))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else if line.trimmingCharacters(in: .whitespaces).isEmpty {
            // Empty line
            Spacer().frame(height: 4)
        } else {
            Text(attributedInline(from: line))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// Parse a task marker line (- [x] ).
    private func parseTask(_ line: String) -> (TaskStatus, String)? {
        let pattern = "^\\s*-\\s*\\[([^\\]]+)\\]\\s*(.*)$"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                  in: line,
                  options: [],
                  range: NSRange(line.startIndex..., in: line)
              ),
              match.numberOfRanges == 3,
              let idRange = Range(match.range(at: 1), in: line),
              let contentRange = Range(match.range(at: 2), in: line)
        else {
            return nil
        }
        let rawId = String(line[idRange])
        let content = String(line[contentRange])
        let status = TaskStatus.forRawValue(rawId)
        return (status, content)
    }

    /// Parse inline Markdown (bold, italic, links) for a single line.
    private func attributedInline(from text: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnly)
        return (try? AttributedString(markdown: text, options: options))
            ?? AttributedString(text)
    }

    /// Match TaskStatus to a color for preview.
    private func tintColor(for status: TaskStatus) -> Color {
        switch status.id {
        case "!": return .red
        case "?": return .yellow
        case "/": return .green
        case ">": return .gray
        case "<": return .gray
        case "*": return .yellow
        case "i": return .blue
        case "\"": return .pink
        case "p": return .green
        case "c": return .red
        case "u": return .green
        case "d": return .red
        case "f": return .orange
        case "k": return .yellow
        case "b": return .red
        case "l": return .red
        case "I": return .yellow
        case "S": return .green
        case "w": return .purple
        default:   return .primary
        }
    }
}