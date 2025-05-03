//
//  ItemTests.swift
//  InboxForObsidian
//
//  Created by Joseph R. Jones and ChatGPT o1 on 4/5/25.
//
@testable import InboxForObsidian
import SwiftData
import Testing
import Foundation

@Suite("ItemTests")
struct ItemTests {
    // In-memory container for 'Item'
    let container: ModelContainer

    // Called before each test to create a fresh container
    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        // Use explicit Schema initializer to ensure in-memory model container can load metadata in tests
        let schema = Schema([Item.self])
        container = try ModelContainer(for: schema, configurations: config)
    }

    @Test("Verify Item initializes with correct timestamp")
    func testItemInitialization() throws {
        // Given a model context
        let context = ModelContext(container)

        // When creating an Item with a specific Date
        let customDate = Date(timeIntervalSince1970: 123456) // arbitrary example
        let newItem = Item(timestamp: customDate)
        context.insert(newItem)
        try context.save()

        // Then the inserted Item should have the correct timestamp
        let fetchDescriptor = FetchDescriptor<Item>()
        let results = try context.fetch(fetchDescriptor)

        #expect(results.count == 1)
        #expect(results.first?.timestamp == customDate)
    }
}

@Suite("InboxItemTests")
struct InboxItemTests {
    // In-memory container for 'InboxItem'
    let container: ModelContainer

    // Called before each test to create a fresh container
    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        // Use explicit Schema initializer to ensure in-memory model container can load metadata in tests
        let schema = Schema([InboxItem.self])
        container = try ModelContainer(for: schema, configurations: config)
    }

    @Test("InboxItem default values check")
    func testInboxItemDefaults() throws {
        let context = ModelContext(container)

        // When creating an InboxItem with no explicit parameters
        let item = InboxItem(content: "Sample note")
        context.insert(item)
        try context.save()

        let fetchDescriptor = FetchDescriptor<InboxItem>()
        let results = try context.fetch(fetchDescriptor)

        #expect(results.count == 1)
        let fetched = results.first!
        
        // Then it should have defaults: synced == false, createdAt is 'now', etc.
        #expect(!fetched.synced)
        // We can do a rough check that createdAt and targetDate are "close to now"
        let now = Date()
        #expect(fetched.createdAt <= now)
        #expect(Calendar.current.isDate(fetched.targetDate, inSameDayAs: now))
    }

    @Test("InboxItem enforces start-of-day for targetDate")
    func testTargetDateIsStartOfDay() throws {
        let context = ModelContext(container)

        // Suppose we pick an arbitrary time of day
        let calendar = Calendar.current
        let midday = calendar.date(bySettingHour: 12, minute: 34, second: 56, of: Date())!
        
        // When creating an InboxItem with that midday date
        let item = InboxItem(content: "Midday test", targetDate: midday)
        context.insert(item)
        try context.save()

        // Then the stored targetDate should be the *start* of that day
        let fetchDescriptor = FetchDescriptor<InboxItem>()
        let results = try context.fetch(fetchDescriptor)

        #expect(results.count == 1)
        let stored = results.first!
        
        // Check that the hour/minute/second are zero
        let components = calendar.dateComponents([.hour, .minute, .second], from: stored.targetDate)
        #expect(components.hour == 0)
        #expect(components.minute == 0)
        #expect(components.second == 0)
    }

    @Suite
    struct TaskStatusTests {
        @Test func knownListIsNotEmptyAndContainsExpectedIdentifiers() {
            #expect(!TaskStatus.known.isEmpty)
            let knownIds = TaskStatus.known.map { $0.id }
            #expect(knownIds.contains("!"))
            #expect(knownIds.contains("?"))
        }

        @Test func forRawValueReturnsExpectedTaskStatusForKnownKeys() {
            // Verify known status "!" yields correct symbol & display name
            let alertStatus = TaskStatus.forRawValue("!")
            #expect(alertStatus.id == "!")
            #expect(alertStatus.symbol == "exclamationmark.triangle")
            #expect(alertStatus.displayName == "Alert")

            // Verify known status "*" (Important) uses its SF Symbol
            let importantStatus = TaskStatus.forRawValue("*")
            #expect(importantStatus.id == "*")
            #expect(importantStatus.symbol == "star.fill")
            #expect(importantStatus.displayName == "Important")
        }

        @Test func forRawValueHandlesUnknownKeysGracefully() {
            let unknownStatus = TaskStatus.forRawValue("Z")
            #expect(unknownStatus.id == "Z")
            #expect(unknownStatus.symbol == nil)
            #expect(unknownStatus.displayName == "Z")
            #expect(unknownStatus.fallbackSymbol == "questionmark.square.dashed")
        }

        @Test func allKnownStatusesHaveNonEmptyDisplayNameAndFallbackSymbol() {
            for status in TaskStatus.known {
                #expect(!status.displayName.isEmpty)
                #expect(!status.fallbackSymbol.isEmpty)
                if let symbol = status.symbol {
                    #expect(status.fallbackSymbol == symbol)
                } else {
                    #expect(status.fallbackSymbol == "questionmark.square.dashed")
                }
            }
        }
    }
}
