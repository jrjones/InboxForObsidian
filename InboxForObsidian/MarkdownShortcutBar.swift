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

    #if os(visionOS)
    var body: some View { visionBody }
    #else
    var body: some View { legacyBody }
    #endif

    @ViewBuilder
    private var legacyBody: some View {
        Group {
            if horizontalSizeClass == .compact {
                // COMPACT: two-row layout
                let half = (statuses.count + 1) / 2
                let topRow = Array(statuses[..<half])
                let bottomRow = Array(statuses[half...])
                VStack(spacing: 8) {
                    HStack(spacing: 16) {
                        syncButton
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
                    ForEach(statuses) { status in
                        statusButton(status)
                    }
                }
            }
        }
        .buttonStyle(.borderless)
    }
#if os(visionOS)
    private var visionBody: some View {
        VStack {} // placeholder for ornament attachment
            .ornament(
                visibility: .visible,
                attachmentAnchor: .scene(.bottom),
                contentAlignment: .center
            ) {
                HStack(spacing: 16) {
                    if showsSyncButton {
                        syncButton
                    }
                    // Only show first 12 shortcuts in visionOS ornament
                    ForEach(statuses.prefix(12)) { status in
                        statusButton(status)
                    }
                }
                .padding(.vertical, 12)
                .glassBackgroundEffect()
            }
    }
    #endif
    // MARK: - Subviews

    private var syncButton: some View {
        Group {
            if showsSyncButton {
                Button(action: onPushToObsidian) {
                    Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                        .labelStyle(.iconOnly)
                }
                .tint(.primary)
                .help("Sync")
                Spacer(minLength: 0)
            }
        }
    }

    private func statusButton(_ status: TaskStatus) -> some View {
        Button {
            // Ensure task is on its own line: add newline if the last line isn't empty
            let lastLine = draftText.components(separatedBy: "\n").last ?? ""
            let prefix = lastLine.trimmingCharacters(in: .whitespaces).isEmpty ? "" : "\n"
            draftText += "\(prefix) - [\(status.id)] "
        } label: {
            Label(status.displayName, systemImage: status.symbol ?? status.fallbackSymbol)
                .labelStyle(.iconOnly)
                .symbolRenderingMode(.hierarchical)
        }
        .tint(tintColor(for: status))
        .help(status.displayName)
    }

    // MARK: - Tint logic

    private func tintColor(for status: TaskStatus) -> Color {
        switch status.id {
        case " ": return .gray
        case "!": return .red
        case "?": return .yellow
        case "/": return .gray
        case "x": return .green
        case "\"": return .orange
        case ">": return .gray
        case "<": return .gray
        case "*": return .yellow
        case "i": return .blue
        case "w": return .purple
        case "I": return .yellow
        case "S": return .green
        case "p": return .green
        case "c": return .red
        case "f": return .orange
        case "b": return .red
        case "l": return .red
        case "u": return .green
        case "d": return .red
        case "k": return .yellow
        default:  return .primary
        }
    }
}
