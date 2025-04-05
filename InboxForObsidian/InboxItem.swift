//
//  MarkdownShortcutBar.swift
//  InboxForObsidian
//
//  Created by Joseph R. Jones on 4/5/25.
//

import Foundation
import SwiftData

@Model
class InboxItem {
    var content: String
    var createdAt: Date
    var targetDate: Date
    var synced: Bool

    init(content: String,
         createdAt: Date = Date(),
         targetDate: Date = Date(),
         synced: Bool = false) {
        self.content = content
        self.createdAt = createdAt
        self.targetDate = Calendar.current.startOfDay(for: targetDate)
        self.synced = synced
    }
}
