//
//  TaskStatus.swift
//  InboxForObsidian
//
//  Created by Joseph R. Jones on 4/5/25.
//

import Foundation

/// Represents a task status with optional SF Symbol & display name.
struct TaskStatus: Identifiable {
    /// For SwiftUI lists, an ID
    let id: String
    
    /// SF Symbol name (e.g. "exclamationmark.triangle"), or nil to fallback to the character
    let symbol: String?
    
    /// Display name (e.g. "Alert", "Idea"); defaults to `id` if not provided
    let displayName: String

    /// Initialize with a unique character, optional symbol, and optional label
    init(rawValue: String, symbol: String? = nil, displayName: String? = nil) {
        self.id = rawValue
        self.symbol = symbol
        self.displayName = displayName ?? rawValue
    }
    
    /// A static list of known statuses with chosen characters & (optionally) SF Symbols.
    static let known: [TaskStatus] = [
        TaskStatus(rawValue: "!",  symbol: "exclamationmark.triangle", displayName: "Alert"),
        TaskStatus(rawValue: "?",  symbol: "questionmark.circle",      displayName: "Question"),
        TaskStatus(rawValue: "/",  symbol: "circle.lefthalf.filled",   displayName: "Partially Done"),
        TaskStatus(rawValue: "b",  symbol: "bookmark.fill",            displayName: "Bookmark"),
        TaskStatus(rawValue: "i",  symbol: "info.circle",              displayName: "Info"),
        TaskStatus(rawValue: "I",  symbol: "lightbulb.fill",           displayName: "Idea"),
        TaskStatus(rawValue: "<",  symbol: "calendar",                 displayName: "Event"),
        
        // Some with no SF Symbols, fallback to just the character:
        TaskStatus(rawValue: "*",  symbol: nil,                        displayName: "Important"),
        TaskStatus(rawValue: "\"", symbol: nil,                        displayName: "Quote"),
        TaskStatus(rawValue: "p",  symbol: nil,                        displayName: "Thumbs Up"),
        TaskStatus(rawValue: "c",  symbol: nil,                        displayName: "Thumbs Down"),
        TaskStatus(rawValue: "u",  symbol: nil,                        displayName: "Chart Up"),
        TaskStatus(rawValue: "d",  symbol: nil,                        displayName: "Chart Down"),
        TaskStatus(rawValue: "S",  symbol: nil,                        displayName: "Dollar"),
        TaskStatus(rawValue: "w",  symbol: nil,                        displayName: "Win"),
    ]

    /// Helper for quick lookups—if an unknown character is passed in, we return a fallback.
    static func forRawValue(_ rawValue: String) -> TaskStatus {
        if let match = known.first(where: { $0.id == rawValue }) {
            return match
        } else {
            // fallback to raw character if unrecognized
            return TaskStatus(rawValue: rawValue)
        }
    }
}
