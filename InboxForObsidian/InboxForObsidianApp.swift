//
//  InboxForObsidianApp.swift
//  InboxForObsidian
//
//  Created by Joseph R. Jones on 4/5/25.
//

import SwiftUI
import SwiftData

@main
struct InboxForObsidianApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [InboxItem.self])
        }
    }
}
