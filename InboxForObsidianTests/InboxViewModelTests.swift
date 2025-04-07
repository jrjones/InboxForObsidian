//
//  InboxViewModelTests.swift
//  InboxForObsidian
//
//  Created by Joseph R. Jones on 4/6/25.
//

import XCTest
import SwiftData
import SwiftUI

@testable import InboxForObsidian

@MainActor
final class InboxViewModelTests: XCTestCase {

    private var container: ModelContainer!
    private var viewModel: InboxViewModel!

    override func setUpWithError() throws {
        // Create an in-memory SwiftData container to isolate tests
        let schema = Schema([InboxItem.self])
        let config = ModelConfiguration(
            nil,                 // optional name
            schema: nil,         // no custom schema override
            isStoredInMemoryOnly: true,
            allowsSave: true,
            groupContainer: .none,
            cloudKitDatabase: .none  // disable CloudKit
        )
        container = try ModelContainer(for: schema, configurations: [config])
        container = try ModelContainer(for: schema, configurations: [config])

        // Initialize the view model with the test context
        viewModel = InboxViewModel(context: container.mainContext)
    }

    override func tearDownWithError() throws {
        container = nil
        viewModel = nil
    }

    /// Tests that finalizing a non-empty draft creates a new InboxItem
    func testFinalizeDraftIfNeeded() throws {
        // Given a non-empty draft
        viewModel.draftText = "Test note"

        // When we finalize
        viewModel.finalizeDraftIfNeeded()

        // Then we should have one InboxItem in the view model
        XCTAssertEqual(viewModel.inboxItems.count, 1)
        XCTAssertEqual(viewModel.inboxItems.first?.content, "Test note")
        XCTAssertTrue(viewModel.draftText.isEmpty, "Draft should reset after saving.")
    }

    /// Tests that calling finalizeDraftIfNeeded() with an empty draft does nothing
    func testFinalizeDraftEmpty() throws {
        // Given an empty draft
        viewModel.draftText = ""

        // When we finalize
        viewModel.finalizeDraftIfNeeded()

        // Then no items should be created
        XCTAssertTrue(viewModel.inboxItems.isEmpty, "Should not create item if draft is empty.")
    }

    /// Tests that newly created items are initially unsynced
    func testNewItemIsUnsynced() throws {
        viewModel.draftText = "A brand new note"
        viewModel.finalizeDraftIfNeeded()

        let newItem = viewModel.inboxItems.first
        XCTAssertNotNil(newItem, "Item should exist.")
        XCTAssertFalse(newItem?.synced ?? true, "New item should not be synced yet.")
    }

    /// Example of testing pushNotesToObsidian in isolation
    ///
    /// Note: Because pushNotesToObsidian uses openURL, we pass a fake `OpenURLAction`.
    /// We can verify the code path is called. If you need deeper testing,
    /// consider dependency-injecting a mock or using a specialized approach.
    func testPushNotesToObsidian() async throws {
        // Insert a couple of new items
        viewModel.draftText = "First note"
        viewModel.finalizeDraftIfNeeded()
        viewModel.draftText = "Second note"
        viewModel.finalizeDraftIfNeeded()

        // Provide a dummy openURL action that always returns .handled
        let mockOpenURL = OpenURLAction { url in
            return .handled
        }

        // When we push notes to Obsidian
        await viewModel.pushNotesToObsidian(openURL: mockOpenURL)

        // Then all items should be synced
        XCTAssertTrue(
            viewModel.inboxItems.allSatisfy { $0.synced },
            "All items should be marked synced after push."
        )
    }
}
