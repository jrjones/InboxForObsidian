import SwiftUI

/// Compact horizontal bar with GTD-style task shortcuts
/// and an optional “sync to Obsidian” action.
struct MarkdownShortcutBar: View {
    /// Binding to the draft markdown text being edited.
    @Binding var draftText: String
    /// Show/hide the “push to Obsidian” button.
    var showsSyncButton: Bool = true
    /// Callback fired when the sync button is tapped.
    let onPushToObsidian: () -> Void

    /// Detect compact vs regular width (e.g. iPhone vs iPad/Mac).
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// All defined task statuses.
    private let statuses = TaskStatus.known

    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                // COMPACT: two-row layout
                let half = (statuses.count + 1) / 2
                let topRow = Array(statuses[..<half])
                let bottomRow = Array(statuses[half...])
                VStack(spacing: 8) {
                    HStack(spacing: 16) {
                        syncButton
                        emptyTaskButton
                        ForEach(topRow) { status in
                            statusButton(status)
                        }
                    }
                    HStack(spacing: 16) {
                        ForEach(bottomRow) { status in
                            statusButton(status)
                        }
                    }
                }
            } else {
                // REGULAR: single-row layout
                HStack(spacing: 16) {
                    syncButton
                    emptyTaskButton
                    ForEach(statuses) { status in
                        statusButton(status)
                    }
                }
            }
        }
        .buttonStyle(.borderless)
    }

    // MARK: - Subviews

    private var syncButton: some View {
        Group {
            if showsSyncButton {
                Button(action: onPushToObsidian) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var emptyTaskButton: some View {
        Button {
            draftText += " - [ ] "
        } label: {
            Image(systemName: "square")
        }
        .help("Empty task")
    }

    private func statusButton(_ status: TaskStatus) -> some View {
        Button {
            draftText += " - [\(status.id)] "
        } label: {
            Image(systemName: status.symbol ?? status.fallbackSymbol)
                .foregroundColor(tintColor(for: status))
        }
        .help(status.displayName)
    }

    // MARK: - Tint logic

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
        default:  return .primary
        }
    }
}