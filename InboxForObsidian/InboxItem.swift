import SwiftData
import Foundation

@Model
final class InboxItem {
    var content: String = ""
    var createdAt: Date = Date()
    var targetDate: Date = Calendar.current.startOfDay(for: Date())
    var synced: Bool = false

    init(
        content: String = "",
        createdAt: Date = Date(),
        targetDate: Date = Calendar.current.startOfDay(for: Date()),
        synced: Bool = false
    ) {
        self.content = content
        self.createdAt = createdAt
        self.targetDate = targetDate
        self.synced = synced
    }
}
