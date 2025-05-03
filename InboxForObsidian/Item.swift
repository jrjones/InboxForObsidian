//
//  Item.swift
//  InboxForObsidian
//
//  Created by Joseph R. Jones on 4/5/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    /// Timestamp when the item was created or captured.
    /// Default value provided for SwiftData/CoreData compatibility.
    var timestamp: Date = Date()
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
