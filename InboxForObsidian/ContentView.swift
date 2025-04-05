import SwiftUI
import SwiftData
import Foundation  // for Date, etc.

// Conditionally import UIKit for iOS, AppKit for macOS:
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase

    @State private var draftText = ""
    @State private var lastBackgroundDate: Date? = nil
    @FocusState private var isTextEditorFocused: Bool

    // Query existing items for the push
    @Query(sort: \InboxItem.createdAt, order: .forward)
    private var inboxItems: [InboxItem]

    var body: some View {
        VStack {
            TextEditor(text: $draftText)
                .focused($isTextEditorFocused)
                .padding()
                #if os(iOS)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        MarkdownShortcutBar(draftText: $draftText)

                    }
                }
                #elseif os(macOS)
                // On macOS, let the toolbar go monochrome
                .toolbar {
                    ToolbarItemGroup {
                        MarkdownShortcutBar(draftText: $draftText)
                    }
                }
                #endif

            HStack {
                Spacer()
                Button("Push to Obsidian") {
                    pushNotesToObsidian()
                }
            }
            .padding()
        }
        .onAppear {
            isTextEditorFocused = true
        }
        .onChange(of: scenePhase, perform: handleScenePhaseChange)
    }

    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .background:
            lastBackgroundDate = Date()
        case .active:
            if let lastBackgroundDate {
                let elapsed = Date().timeIntervalSince(lastBackgroundDate)
                if elapsed > 30 {
                    finalizeDraftIfNeeded()
                }
            }
        default:
            break
        }
    }

    private func finalizeDraftIfNeeded() {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newItem = InboxItem(content: trimmed)
        context.insert(newItem)
        try? context.save()

        draftText = ""
    }

    private func pushNotesToObsidian() {
        let unsyncedItems = inboxItems.filter { !$0.synced }
        let groupedByDate = Dictionary(grouping: unsyncedItems, by: \.targetDate)

        for (date, items) in groupedByDate {
            let combined = items.map(\.content).joined(separator: "\n\n")
            if let url = buildObsidianURL(for: date, content: combined) {
                #if os(iOS)
                // iOS: use UIApplication
                UIApplication.shared.open(url) { success in
                    if success {
                        markItemsSynced(items)
                    } else {
                        // Handle open-failure
                    }
                }
                #elseif os(macOS)
                // macOS: use NSWorkspace
                NSWorkspace.shared.open(url)
                markItemsSynced(items)
                #endif
            }
        }
    }

    private func buildObsidianURL(for date: Date, content: String) -> URL? {
        let vaultName = "MainVault"
        let filePath = makeDailyFilePath(for: date)
        let encodedContent = content.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? ""

        var components = URLComponents(string: "obsidian://actions-uri/note/append")
        components?.queryItems = [
            URLQueryItem(name: "vault", value: vaultName),
            URLQueryItem(name: "file", value: filePath),
            URLQueryItem(name: "content", value: encodedContent),
            URLQueryItem(name: "create-if-not-found", value: "true"),
            URLQueryItem(name: "silent", value: "true")
        ]
        return components?.url
    }

    private func markItemsSynced(_ items: [InboxItem]) {
        for item in items {
            item.synced = true
        }
        try? context.save()
    }

    private func makeDailyFilePath(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let filename = formatter.string(from: date)
        return "Daily/\(filename)"
    }

    private func handlePaste() {
        #if canImport(UIKit)
        if let str = UIPasteboard.general.string {
            draftText += str
        }
        #elseif os(macOS)
        if let str = NSPasteboard.general.string(forType: .string) {
            draftText += str
        }
        #endif
    }
}
