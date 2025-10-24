//
//  PerformanceTests.swift
//  FancyAreasTests
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import XCTest
import CoreGraphics
@testable import FancyAreas

final class PerformanceTests: XCTestCase {

    var zoneManager: ZoneManager!
    var testLayout: Layout!

    override func setUpWithError() throws {
        zoneManager = ZoneManager.shared

        // Create a complex layout with many zones
        let display = Display(
            displayID: "test-display",
            name: "Test Display",
            resolution: CGSize(width: 1920, height: 1080),
            position: CGPoint(x: 0, y: 0),
            isPrimary: true
        )

        // Create 20 zones (5x4 grid)
        var zones: [Zone] = []
        let cols = 5
        let rows = 4
        let zoneWidth = 1920.0 / Double(cols)
        let zoneHeight = 1080.0 / Double(rows)

        for row in 0..<rows {
            for col in 0..<cols {
                let zone = Zone(
                    zoneNumber: row * cols + col + 1,
                    displayID: "test-display",
                    bounds: CGRect(
                        x: Double(col) * zoneWidth,
                        y: Double(row) * zoneHeight,
                        width: zoneWidth,
                        height: zoneHeight
                    )
                )
                zones.append(zone)
            }
        }

        testLayout = Layout(
            layoutName: "Performance Test Layout",
            layoutType: .zonesOnly,
            monitorConfiguration: MonitorConfiguration(displays: [display]),
            zones: zones
        )
    }

    override func tearDownWithError() throws {
        zoneManager.deactivateLayout()
    }

    // MARK: - Zone Detection Performance

    func testZoneDetectionPerformance() {
        zoneManager.activateLayout(testLayout)

        // Target: < 1ms per detection
        measure {
            for _ in 0..<1000 {
                let randomX = CGFloat.random(in: 0...1920)
                let randomY = CGFloat.random(in: 0...1080)
                let point = CGPoint(x: randomX, y: randomY)
                _ = zoneManager.detectZone(at: point, on: "test-display")
            }
        }
    }

    func testZoneActivationPerformance() {
        // Target: < 500ms
        measure {
            zoneManager.activateLayout(testLayout)
        }
    }

    // MARK: - Layout File Performance

    func testLayoutSavePerformance() {
        let fileManager = LayoutFileManager.shared

        // Target: < 100ms
        measure {
            try? fileManager.saveLayout(testLayout)
        }
    }

    func testLayoutLoadPerformance() {
        let fileManager = LayoutFileManager.shared
        try? fileManager.saveLayout(testLayout)

        // Target: < 100ms
        measure {
            _ = try? fileManager.loadLayout(id: testLayout.id)
        }
    }

    func testListLayoutsPerformance() {
        let fileManager = LayoutFileManager.shared

        // Save multiple layouts
        for i in 0..<10 {
            var layout = testLayout!
            layout.id = UUID()
            layout.layoutName = "Layout \(i)"
            try? fileManager.saveLayout(layout)
        }

        // Target: < 50ms
        measure {
            _ = try? fileManager.listLayouts()
        }
    }

    // MARK: - Spatial Grid Performance

    func testSpatialGridBuildPerformance() {
        // This is tested implicitly in zone activation
        // Target: < 100ms to build grid for 20 zones
        measure {
            zoneManager.activateLayout(testLayout)
        }
    }

    // MARK: - Memory Usage

    func testMemoryUsageWithMultipleLayouts() {
        let fileManager = LayoutFileManager.shared

        // Save 10 layouts
        for i in 0..<10 {
            var layout = testLayout!
            layout.id = UUID()
            layout.layoutName = "Layout \(i)"
            try? fileManager.saveLayout(layout)
        }

        // Load all layouts - should not consume excessive memory
        measure(metrics: [XCTMemoryMetric()]) {
            _ = try? fileManager.listLayouts()
        }
    }

    // MARK: - JSON Encoding Performance

    func testJSONEncodingPerformance() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        // Target: < 10ms
        measure {
            _ = try? encoder.encode(testLayout)
        }
    }

    func testJSONDecodingPerformance() {
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(testLayout)

        let decoder = JSONDecoder()

        // Target: < 10ms
        measure {
            _ = try? decoder.decode(Layout.self, from: jsonData)
        }
    }

    // MARK: - Cleanup

    override func tearDown() {
        // Clean up test files
        let fileManager = LayoutFileManager.shared
        let layouts = (try? fileManager.listLayouts()) ?? []

        for layout in layouts {
            if layout.layoutName.contains("Test") || layout.layoutName.contains("Layout") {
                try? fileManager.deleteLayout(id: layout.id)
            }
        }
    }
}

// MARK: - Performance Metrics Documentation

/*
 Performance Targets:

 1. Zone Detection: < 1ms per lookup
    - Uses spatial grid for O(1) average case
    - Handles 1000+ detections per second

 2. Layout Activation: < 500ms
    - Includes zone cache building
    - Spatial grid construction
    - Memory allocation

 3. File Operations:
    - Save: < 100ms
    - Load: < 100ms
    - List (10 layouts): < 50ms

 4. JSON Serialization:
    - Encode: < 10ms
    - Decode: < 10ms

 5. Memory Usage:
    - Idle: < 50MB
    - Active (1 layout): < 75MB
    - Active (10 layouts): < 100MB

 6. Startup Time:
    - Cold start: < 1 second
    - Permission check: < 100ms
    - Last layout restore: < 500ms

 7. Zone Overlay:
    - Display: < 100ms
    - Update: 60 FPS (16.67ms per frame)
    - Hide: < 100ms

 8. Window Snapping:
    - Detection: < 5ms
    - Animation start: < 10ms
    - Animation smooth: 60 FPS
 */
