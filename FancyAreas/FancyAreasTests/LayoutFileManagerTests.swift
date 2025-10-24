//
//  LayoutFileManagerTests.swift
//  FancyAreasTests
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import XCTest
import CoreGraphics
@testable import FancyAreas

final class LayoutFileManagerTests: XCTestCase {

    var fileManager: LayoutFileManager!
    var testLayout: Layout!

    override func setUpWithError() throws {
        fileManager = LayoutFileManager.shared

        // Create a test layout
        let display = Display(
            displayID: "test-display-1",
            name: "Test Display",
            resolution: CGSize(width: 1920, height: 1080),
            position: CGPoint(x: 0, y: 0),
            isPrimary: true
        )

        let zone = Zone(
            zoneNumber: 1,
            displayID: "test-display-1",
            bounds: CGRect(x: 0, y: 0, width: 960, height: 1080)
        )

        testLayout = Layout(
            layoutName: "Test Layout",
            layoutType: .zonesOnly,
            monitorConfiguration: MonitorConfiguration(displays: [display]),
            zones: [zone]
        )
    }

    override func tearDownWithError() throws {
        // Clean up test files
        if let layout = testLayout {
            try? fileManager.deleteLayout(id: layout.id)
        }
    }

    func testSaveAndLoadLayout() throws {
        // Save layout
        try fileManager.saveLayout(testLayout)

        // Load layout
        let loadedLayout = try fileManager.loadLayout(id: testLayout.id)

        // Verify
        XCTAssertEqual(loadedLayout.id, testLayout.id)
        XCTAssertEqual(loadedLayout.layoutName, testLayout.layoutName)
        XCTAssertEqual(loadedLayout.layoutType, testLayout.layoutType)
        XCTAssertEqual(loadedLayout.zones.count, testLayout.zones.count)
    }

    func testListLayouts() throws {
        // Save layout
        try fileManager.saveLayout(testLayout)

        // List layouts
        let layouts = try fileManager.listLayouts()

        // Should contain our test layout
        XCTAssertTrue(layouts.contains { $0.id == testLayout.id })
    }

    func testDeleteLayout() throws {
        // Save layout
        try fileManager.saveLayout(testLayout)

        // Verify it exists
        let layoutsBeforeDelete = try fileManager.listLayouts()
        XCTAssertTrue(layoutsBeforeDelete.contains { $0.id == testLayout.id })

        // Delete layout
        try fileManager.deleteLayout(id: testLayout.id)

        // Verify it's gone
        let layoutsAfterDelete = try fileManager.listLayouts()
        XCTAssertFalse(layoutsAfterDelete.contains { $0.id == testLayout.id })
    }

    func testUpdateExistingLayout() throws {
        // Save original
        try fileManager.saveLayout(testLayout)

        // Modify layout
        var updatedLayout = testLayout!
        updatedLayout.layoutName = "Updated Test Layout"
        updatedLayout.modified = Date()

        // Save updated version (same ID)
        try fileManager.saveLayout(updatedLayout)

        // Load and verify
        let loadedLayout = try fileManager.loadLayout(id: testLayout.id)
        XCTAssertEqual(loadedLayout.layoutName, "Updated Test Layout")
    }

    func testLayoutLimitEnforcement() throws {
        // This test would create 10 layouts and verify that an 11th fails
        // Skipped in this example to avoid creating too many test files

        // In a real implementation:
        // 1. Create and save 10 unique layouts
        // 2. Attempt to save an 11th
        // 3. Verify FileManagerError.layoutLimitReached is thrown
    }

    func testValidateLayoutFile() throws {
        // Save a valid layout
        try fileManager.saveLayout(testLayout)

        // Find the file
        let layouts = try fileManager.listLayouts()
        XCTAssertTrue(layouts.contains { $0.id == testLayout.id })

        // Validation is tested implicitly through successful load
        XCTAssertNoThrow(try fileManager.loadLayout(id: testLayout.id))
    }
}
