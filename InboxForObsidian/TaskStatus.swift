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
        TaskStatus(rawValue: "!",  symbol: "exclamationmark.triangle",    displayName: "Alert"),
        TaskStatus(rawValue: "?",  symbol: "questionmark.circle",         displayName: "Question"),
        TaskStatus(rawValue: "/",  symbol: "circle.lefthalf.filled",      displayName: "Partially Done"),
        TaskStatus(rawValue: ">",  symbol: "arrow.right",                 displayName: "Moved"),
        TaskStatus(rawValue: "<",  symbol: "arrow.left",                  displayName: "Event"),
        TaskStatus(rawValue: "*",  symbol: "star.fill",                   displayName: "Important"),
        TaskStatus(rawValue: "i",  symbol: "info.circle",                 displayName: "Information"),
        TaskStatus(rawValue: "\"", symbol: "text.quote",                  displayName: "Quotation"),
        TaskStatus(rawValue: "p",  symbol: "hand.thumbsup.fill",          displayName: "Thumbs Up"),
        TaskStatus(rawValue: "c",  symbol: "hand.thumbsdown.fill",        displayName: "Thumbs Down"),
        TaskStatus(rawValue: "u",  symbol: "arrow.up",                    displayName: "Up trend"),
        TaskStatus(rawValue: "d",  symbol: "arrow.down",                  displayName: "Down trend"),
        TaskStatus(rawValue: "f",  symbol: "flame.fill",                  displayName: "Fire"),
        TaskStatus(rawValue: "k",  symbol: "key.fill",                    displayName: "Key"),
        TaskStatus(rawValue: "b",  symbol: "bookmark.fill",               displayName: "Bookmark"),
        TaskStatus(rawValue: "l",  symbol: "mappin.and.ellipse",          displayName: "Location"),
        TaskStatus(rawValue: "I",  symbol: "lightbulb.fill",              displayName: "Idea"),
        TaskStatus(rawValue: "S",  symbol: "dollarsign.circle.fill",      displayName: "Savings/Spend"),
        TaskStatus(rawValue: "w",  symbol: "trophy.fill",                 displayName: "Win"),
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

extension TaskStatus {
    /// If symbol is nil, return a default symbol like "questionmark.square.dashed"
    var fallbackSymbol: String {
        symbol ?? "questionmark.square.dashed"
    }
}
