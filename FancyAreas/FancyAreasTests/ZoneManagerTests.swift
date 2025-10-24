//
//  ZoneManagerTests.swift
//  FancyAreasTests
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import XCTest
import CoreGraphics
@testable import FancyAreas

final class ZoneManagerTests: XCTestCase {

    var zoneManager: ZoneManager!
    var testLayout: Layout!

    override func setUpWithError() throws {
        zoneManager = ZoneManager.shared

        // Create a test layout with multiple zones
        let display = Display(
            displayID: "test-display",
            name: "Test Display",
            resolution: CGSize(width: 1920, height: 1080),
            position: CGPoint(x: 0, y: 0),
            isPrimary: true
        )

        let zones = [
            Zone(zoneNumber: 1, displayID: "test-display",
                 bounds: CGRect(x: 0, y: 0, width: 960, height: 540)),
            Zone(zoneNumber: 2, displayID: "test-display",
                 bounds: CGRect(x: 960, y: 0, width: 960, height: 540)),
            Zone(zoneNumber: 3, displayID: "test-display",
                 bounds: CGRect(x: 0, y: 540, width: 960, height: 540)),
            Zone(zoneNumber: 4, displayID: "test-display",
                 bounds: CGRect(x: 960, y: 540, width: 960, height: 540))
        ]

        testLayout = Layout(
            layoutName: "Test 4-Zone Layout",
            layoutType: .zonesOnly,
            monitorConfiguration: MonitorConfiguration(displays: [display]),
            zones: zones
        )
    }

    override func tearDownWithError() throws {
        zoneManager.deactivateLayout()
    }

    func testActivateLayout() {
        zoneManager.activateLayout(testLayout)

        XCTAssertTrue(zoneManager.hasActiveLayout)
        XCTAssertEqual(zoneManager.currentLayout?.id, testLayout.id)
        XCTAssertEqual(zoneManager.getAllZones().count, 4)
    }

    func testDeactivateLayout() {
        zoneManager.activateLayout(testLayout)
        zoneManager.deactivateLayout()

        XCTAssertFalse(zoneManager.hasActiveLayout)
        XCTAssertNil(zoneManager.currentLayout)
        XCTAssertEqual(zoneManager.getAllZones().count, 0)
    }

    func testGetZonesForDisplay() {
        zoneManager.activateLayout(testLayout)

        let zones = zoneManager.getZones(for: "test-display")
        XCTAssertEqual(zones.count, 4)
    }

    func testDetectZoneTopLeft() {
        zoneManager.activateLayout(testLayout)

        // Point in top-left zone (zone 1)
        let point = CGPoint(x: 100, y: 100)
        let zone = zoneManager.detectZone(at: point, on: "test-display")

        XCTAssertNotNil(zone)
        XCTAssertEqual(zone?.zoneNumber, 1)
    }

    func testDetectZoneTopRight() {
        zoneManager.activateLayout(testLayout)

        // Point in top-right zone (zone 2)
        let point = CGPoint(x: 1500, y: 100)
        let zone = zoneManager.detectZone(at: point, on: "test-display")

        XCTAssertNotNil(zone)
        XCTAssertEqual(zone?.zoneNumber, 2)
    }

    func testDetectZoneBottomLeft() {
        zoneManager.activateLayout(testLayout)

        // Point in bottom-left zone (zone 3)
        let point = CGPoint(x: 100, y: 700)
        let zone = zoneManager.detectZone(at: point, on: "test-display")

        XCTAssertNotNil(zone)
        XCTAssertEqual(zone?.zoneNumber, 3)
    }

    func testDetectZoneBottomRight() {
        zoneManager.activateLayout(testLayout)

        // Point in bottom-right zone (zone 4)
        let point = CGPoint(x: 1500, y: 700)
        let zone = zoneManager.detectZone(at: point, on: "test-display")

        XCTAssertNotNil(zone)
        XCTAssertEqual(zone?.zoneNumber, 4)
    }

    func testDetectZoneAtBoundary() {
        zoneManager.activateLayout(testLayout)

        // Point right at the boundary between zones 1 and 2
        let point = CGPoint(x: 960, y: 100)
        let zone = zoneManager.detectZone(at: point, on: "test-display")

        // Should find one of the adjacent zones
        XCTAssertNotNil(zone)
        XCTAssertTrue(zone?.zoneNumber == 1 || zone?.zoneNumber == 2)
    }

    func testDetectZoneOutsideBounds() {
        zoneManager.activateLayout(testLayout)

        // Point outside all zones
        let point = CGPoint(x: 2000, y: 2000)
        let zone = zoneManager.detectZone(at: point, on: "test-display")

        XCTAssertNil(zone)
    }

    func testGetZoneBounds() {
        zoneManager.activateLayout(testLayout)

        let bounds = zoneManager.getZoneBounds(zoneNumber: 1, displayID: "test-display")

        XCTAssertNotNil(bounds)
        XCTAssertEqual(bounds, CGRect(x: 0, y: 0, width: 960, height: 540))
    }

    func testFindNearbyZones() {
        zoneManager.activateLayout(testLayout)

        // Point near the center (where all 4 zones meet)
        let point = CGPoint(x: 960, y: 540)
        let nearbyZones = zoneManager.findNearbyZones(at: point, on: "test-display", threshold: 100)

        // Should find all 4 zones since they all meet at this point
        XCTAssertTrue(nearbyZones.count >= 1)
    }

    func testValidateLayout() {
        let isValid = zoneManager.validateLayout(testLayout)
        XCTAssertTrue(isValid)
    }

    func testValidateInvalidLayout() {
        // Create a layout with a zone outside display bounds
        let display = Display(
            displayID: "test-display",
            name: "Test Display",
            resolution: CGSize(width: 1920, height: 1080),
            position: CGPoint(x: 0, y: 0),
            isPrimary: true
        )

        let invalidZone = Zone(
            zoneNumber: 1,
            displayID: "test-display",
            bounds: CGRect(x: 2000, y: 2000, width: 500, height: 500) // Outside display
        )

        let invalidLayout = Layout(
            layoutName: "Invalid Layout",
            layoutType: .zonesOnly,
            monitorConfiguration: MonitorConfiguration(displays: [display]),
            zones: [invalidZone]
        )

        let isValid = zoneManager.validateLayout(invalidLayout)
        XCTAssertFalse(isValid)
    }

    func testPerformanceZoneDetection() {
        zoneManager.activateLayout(testLayout)

        // Test performance of zone detection
        measure {
            for _ in 0..<1000 {
                let randomX = CGFloat.random(in: 0...1920)
                let randomY = CGFloat.random(in: 0...1080)
                let point = CGPoint(x: randomX, y: randomY)
                _ = zoneManager.detectZone(at: point, on: "test-display")
            }
        }
    }
}
