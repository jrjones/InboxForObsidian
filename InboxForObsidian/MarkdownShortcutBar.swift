import SwiftUI

struct MarkdownShortcutBar: View {
    @Binding var draftText: String

    var body: some View {
        HStack {
            // A basic “empty task” button
            Button {
                draftText += "- [ ] "
            } label: {
                Image(systemName: "square")
            }

            // A single known status (Alert) for demonstration
            Button {
                insertTaskMarker(TaskStatus.forRawValue("!"))
            } label: {
                Image(systemName: "exclamationmark.triangle")
            }

            // Dropdown menu for all known statuses
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
