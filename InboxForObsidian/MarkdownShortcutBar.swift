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

   var body: some View {
       HStack(spacing: 16) {
           // Optional sync button
           if showsSyncButton {
               Button(action: onPushToObsidian) {
                   Image(systemName: "arrow.triangle.2.circlepath")
               }
               Spacer(minLength: 0)
           }

           // Empty task
           Button {
               draftText += " - [ ] "
           } label: {
               Image(systemName: "square")
           }
           .help("Empty task")

           // Common task-status shortcuts
           ForEach(TaskStatus.known) { status in
               Button {
                   draftText += " - [\(status.id)] "
               } label: {
                   Image(systemName: status.symbol ?? status.fallbackSymbol)
                       .foregroundColor(tintColor(for: status))
               }
               .help(status.displayName)
           }
       }
       .buttonStyle(.borderless)
   }

   /// Basic tinting to match Obsidian’s task colors
   private func tintColor(for status: TaskStatus) -> Color {
       switch status.id {
       case "!": return .red          // Alert / Important
       case "?": return .yellow       // Question
       case "/": return .green        // In-Progress
       case ">": return .gray         // Forwarded
       case "<": return .gray         // Scheduled
       case "*": return .yellow       // Starred
       case "i": return .blue         // Information
       case "\"": return .pink        // Quote
       case "p": return .green        // Delegated (pending)
       case "c": return .red          // Cancelled
       case "u": return .green        // Done
       case "d": return .red          // Dropped
       case "f": return .orange       // Flagged
       case "k": return .yellow       // Link
       case "b": return .red          // Bug
       case "l": return .red          // Late
       case "I": return .yellow       // Idea
       case "S": return .green        // Someday
       case "w": return .purple       // Waiting
       default:  return .primary
       }
   }
}
