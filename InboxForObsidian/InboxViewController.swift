//
//  File.swift
//  InboxForObsidian
//
//  Created by Joseph R. Jones on 4/6/25.
//
import SwiftUI
import SwiftData
import Foundation
import Combine

#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

@MainActor
class InboxViewModel: ObservableObject {
    private let context: ModelContext

    /// Draft text currently in the editor.
    @Published var draftText: String = ""

    /// All inbox items loaded from storage.
    @Published var inboxItems: [InboxItem] = []

    /// Timestamp when the app last went to the background.
    @Published var lastBackgroundDate: Date? = nil

    init(context: ModelContext) {
        self.context = context
        loadInboxItems()
    }

    /// Fetch all `InboxItem` entries from storage, sorted by creation date.
    func loadInboxItems() {
        do {
            let descriptor = FetchDescriptor<InboxItem>(
                sortBy: [SortDescriptor(\.createdAt, order: .forward)]
            )
            inboxItems = try context.fetch(descriptor)
        } catch {
            print("Error fetching InboxItems: \(error)")
            inboxItems = []
        }
    }

    /// Finalize the current draft: if non-empty, save it as a new `InboxItem`.
    func finalizeDraftIfNeeded() {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let newItem = InboxItem(content: trimmed)
        context.insert(newItem)
        do {
            try context.save()
            // Append the new item to our local list and reset the draft.
            inboxItems.append(newItem)
            draftText = ""
        } catch {
            print("Failed to save new item: \(error)")
        }
    }

    /// Start a new draft by finalizing the current one (if needed).
    func startNewDraft() {
        finalizeDraftIfNeeded()
        // The view will handle focusing the text editor for the new draft.
    }

    /// Handle app lifecycle changes. Save draft if returning from background after a threshold.
    func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .background:
            lastBackgroundDate = Date()
        case .active:
            if let lastDate = lastBackgroundDate {
                let elapsed = Date().timeIntervalSince(lastDate)
                if elapsed > 30 {
                    finalizeDraftIfNeeded()
                }
            }
        default:
            break
        }
    }

    /// Push all unsynced notes to Obsidian via URL scheme, marking them as synced on success.
    func pushNotesToObsidian(openURL: OpenURLAction) async {
        let unsyncedItems = inboxItems.filter { !$0.synced }
        guard !unsyncedItems.isEmpty else { return }

        // Group unsynced notes by target date.
        let groupedByDate = Dictionary(grouping: unsyncedItems, by: \.targetDate)
        for (date, items) in groupedByDate {
            // Combine contents of notes for the same date.
            let combinedContent = items.map(\.content).joined(separator: "\n\n")
            guard let url = buildObsidianURL(for: date, content: combinedContent) else {
                continue  // Skip if URL construction fails.
            }

            // Open the Obsidian URL and await the result (accepted or not).
            let openedSuccessfully = await withCheckedContinuation { continuation in
                openURL(url) { accepted in
                    continuation.resume(returning: accepted)
                }
            }
            if openedSuccessfully {
                // Mark items as synced and save.
                for item in items {
                    item.synced = true
                }
                do {
                    try context.save()
                } catch {
                    print("Failed to save synced status: \(error)")
                }
            } else {
                // Optionally handle failure (Obsidian not installed or URL not opened).
                // For example, show an alert to the user (not implemented here).
            }
        }
    }

    /// Build an Obsidian URL to append content to the daily note for the given date.
    private func buildObsidianURL(for date: Date, content: String) -> URL? {
        // Vault name configured in Info.plist (defaults to "Obsidian Sandbox" if not set).
        let vaultName = Bundle.main.object(forInfoDictionaryKey: "ObsidianVaultName") as? String
            ?? "Obsidian Sandbox"
        let filePath = makeDailyFilePath(for: date)
        var components = URLComponents(string: "obsidian://actions-uri/note/append")
        components?.queryItems = [
            URLQueryItem(name: "vault", value: vaultName),
            URLQueryItem(name: "file", value: filePath),
            URLQueryItem(name: "content", value: "\n" + content),
            URLQueryItem(name: "create-if-not-found", value: "true"),
            URLQueryItem(name: "silent", value: "false")
        ]
        return components?.url
    }

    /// Compute the Obsidian daily note file path for a given date (e.g., "daily/2025-04-06").
    private func makeDailyFilePath(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let filename = formatter.string(from: date)
        return "daily/\(filename)"
    }

    /// Append the current clipboard text to the draft text.
    func handlePaste() {
        #if canImport(UIKit)
        if let pastedText = UIPasteboard.general.string {
            draftText.append(pastedText)
        }
        #elseif os(macOS)
        if let pastedText = NSPasteboard.general.string(forType: .string) {
            draftText.append(pastedText)
        }
        #endif
    }
}
