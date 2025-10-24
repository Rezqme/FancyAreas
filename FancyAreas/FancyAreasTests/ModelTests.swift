//
//  ModelTests.swift
//  FancyAreasTests
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import XCTest
import CoreGraphics
@testable import FancyAreas

final class ModelTests: XCTestCase {

    func testLayoutEncodeDecode() throws {
        // Create a test layout
        let display = Display(
            displayID: "display-1",
            name: "Built-in Display",
            resolution: CGSize(width: 1920, height: 1080),
            position: CGPoint(x: 0, y: 0),
            isPrimary: true
        )

        let zone = Zone(
            zoneNumber: 1,
            displayID: "display-1",
            bounds: CGRect(x: 0, y: 0, width: 960, height: 1080)
        )

        let layout = Layout(
            layoutName: "Test Layout",
            layoutType: .zonesOnly,
            monitorConfiguration: MonitorConfiguration(displays: [display]),
            zones: [zone]
        )

        // Encode to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(layout)

        // Decode from JSON
        let decoder = JSONDecoder()
        let decodedLayout = try decoder.decode(Layout.self, from: jsonData)

        // Verify
        XCTAssertEqual(layout.layoutName, decodedLayout.layoutName)
        XCTAssertEqual(layout.layoutType, decodedLayout.layoutType)
        XCTAssertEqual(layout.zones.count, decodedLayout.zones.count)
        XCTAssertEqual(layout.monitorConfiguration.displays.count, decodedLayout.monitorConfiguration.displays.count)
    }

    func testZoneWithAssignedApp() throws {
        let app = AssignedApp(
            bundleID: "com.apple.Safari",
            appName: "Safari",
            windowTitle: "GitHub"
        )

        let zone = Zone(
            zoneNumber: 1,
            displayID: "display-1",
            bounds: CGRect(x: 0, y: 0, width: 960, height: 1080),
            assignedApp: app
        )

        // Encode and decode
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(zone)

        let decoder = JSONDecoder()
        let decodedZone = try decoder.decode(Zone.self, from: jsonData)

        XCTAssertEqual(zone.zoneNumber, decodedZone.zoneNumber)
        XCTAssertEqual(zone.assignedApp?.bundleID, decodedZone.assignedApp?.bundleID)
        XCTAssertEqual(zone.assignedApp?.appName, decodedZone.assignedApp?.appName)
    }

    func testGridSettingsValidation() {
        var settings = GridSettings(columns: 15, rows: 10, spacing: 25)
        settings.validate()

        // Should be clamped to valid ranges
        XCTAssertEqual(settings.columns, 12) // Max is 12
        XCTAssertEqual(settings.rows, 8)     // Max is 8
        XCTAssertEqual(settings.spacing, 20) // Max is 20
    }

    func testMonitorConfigurationCompatibility() {
        let display1 = Display(
            displayID: "display-1",
            name: "Display 1",
            resolution: CGSize(width: 1920, height: 1080),
            position: CGPoint(x: 0, y: 0),
            isPrimary: true
        )

        let display2 = Display(
            displayID: "display-2",
            name: "Display 2",
            resolution: CGSize(width: 2560, height: 1440),
            position: CGPoint(x: 1920, y: 0),
            isPrimary: false
        )

        let config1 = MonitorConfiguration(displays: [display1, display2])
        let config2 = MonitorConfiguration(displays: [display1, display2])
        let config3 = MonitorConfiguration(displays: [display1])

        // Same displays should be compatible
        XCTAssertTrue(config1.isCompatible(with: config2))

        // Different number of displays should not be compatible
        XCTAssertFalse(config1.isCompatible(with: config3))
    }

    func testCGRectCodable() throws {
        let rect = CGRect(x: 10, y: 20, width: 100, height: 200)

        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(rect)

        let decoder = JSONDecoder()
        let decodedRect = try decoder.decode(CGRect.self, from: jsonData)

        XCTAssertEqual(rect, decodedRect)
    }
}
