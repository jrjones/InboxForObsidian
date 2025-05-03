import SwiftData
import Foundation

@Model final class InboxItem: Identifiable {
    /// Unique identifier for this item (for Identifiable conformance).
    var id: UUID = UUID()

    /// The content of the captured note or task.
    var content: String = ""

    /// Timestamp when the item was created/captured.
    var createdAt: Date = Date()

    /// The target date (daily note date) for this item in Obsidian.
    var targetDate: Date = Date()

    /// Flag indicating whether this item has been synced to Obsidian.
    var synced: Bool = false

    init(
        id: UUID = UUID(),
        content: String = "",
        createdAt: Date = Date(),
        targetDate: Date = Calendar.current.startOfDay(for: Date()),
        synced: Bool = false
    ) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        // Ensure targetDate is normalized to start of day
        self.targetDate = Calendar.current.startOfDay(for: targetDate)
        self.synced = synced
    }
}
