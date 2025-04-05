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
                        if let symbol = status.symbol {
                            // If there's an SF Symbol, show that icon + display name
                            Label(status.displayName, systemImage: symbol)
                        } else {
                            // Otherwise, display a fallback circle icon + display name
                            HStack {
                                ZStack {
                                    Circle()
                                        .stroke(Color.primary, lineWidth: 1)
                                        .frame(width: 20, height: 20)
                                    Text(status.id)
                                        .font(.system(size: 11, weight: .bold))
                                }
                                Text(status.displayName)
                            }
                        }
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
