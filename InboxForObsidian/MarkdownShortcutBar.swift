import SwiftUI

struct MarkdownShortcutBar: View {
    @Binding var draftText: String
    // A closure the parent passes in so we can call it here
    let onPushToObsidian: () -> Void

    var body: some View {
        HStack {
            // Push-to-Obsidian button
            Button {
                onPushToObsidian()
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
            }

            Spacer()

            // Empty task button
            Button {
                draftText += "- [ ] "
            } label: {
                Image(systemName: "square")
            }

            // A single known status (Alert) for demonstration
            Button {
                insertTaskMarker(.forRawValue("!"))
            } label: {
                Image(systemName: "exclamationmark.triangle")
            }

            // Dropdown menu for other statuses
            Menu {
                ForEach(TaskStatus.known) { status in
                    Button {
                        insertTaskMarker(status)
                    } label: {
                        Label(status.displayName, systemImage: status.fallbackSymbol)
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
        .buttonStyle(.borderless)
    }

    private func insertTaskMarker(_ status: TaskStatus) {
        draftText += "- [\(status.id)] "
    }
}
