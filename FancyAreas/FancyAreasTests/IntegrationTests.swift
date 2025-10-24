//
//  IntegrationTests.swift
//  FancyAreasTests
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import XCTest
import CoreGraphics
@testable import FancyAreas

final class IntegrationTests: XCTestCase {

    // MARK: - Layout Workflow Tests

    func testCompleteLayoutWorkflow() {
        let fileManager = LayoutFileManager.shared
        let zoneManager = ZoneManager.shared

        // 1. Create a new layout
        let display = Display(
            displayID: "test-display",
            name: "Test Display",
            resolution: CGSize(width: 1920, height: 1080),
            position: CGPoint(x: 0, y: 0),
            isPrimary: true
        )

        let zones = [
            Zone(zoneNumber: 1, displayID: "test-display", bounds: CGRect(x: 0, y: 0, width: 960, height: 1080)),
            Zone(zoneNumber: 2, displayID: "test-display", bounds: CGRect(x: 960, y: 0, width: 960, height: 1080))
        ]

        let layout = Layout(
            layoutName: "Integration Test Layout",
            layoutType: .zonesOnly,
            monitorConfiguration: MonitorConfiguration(displays: [display]),
            zones: zones
        )

        // 2. Save the layout
        XCTAssertNoThrow(try fileManager.saveLayout(layout))

        // 3. Load the layout
        var loadedLayout: Layout?
        XCTAssertNoThrow(loadedLayout = try fileManager.loadLayout(id: layout.id))
        XCTAssertNotNil(loadedLayout)
        XCTAssertEqual(loadedLayout?.id, layout.id)

        // 4. Activate the layout
        guard let loadedLayout = loadedLayout else {
            XCTFail("Failed to load layout")
            return
        }
        zoneManager.activateLayout(loadedLayout)
        XCTAssertTrue(zoneManager.hasActiveLayout)

        // 5. Detect zones
        let zone = zoneManager.detectZone(at: CGPoint(x: 500, y: 500), on: "test-display")
        XCTAssertNotNil(zone)
        XCTAssertEqual(zone?.zoneNumber, 1)

        // 6. Deactivate
        zoneManager.deactivateLayout()
        XCTAssertFalse(zoneManager.hasActiveLayout)

        // 7. Delete the layout
        XCTAssertNoThrow(try fileManager.deleteLayout(id: layout.id))
    }

    // MARK: - Template Integration Tests

    func testTemplateToLayoutWorkflow() {
        let templateLibrary = TemplateLibrary.shared
        let fileManager = LayoutFileManager.shared

        // 1. Get a template
        let template = templateLibrary.twoColumnSplit
        XCTAssertEqual(template.name, "2 Column Split")

        // 2. Generate zones from template
        let displayID = "test-display"
        let displaySize = CGSize(width: 1920, height: 1080)
        let zones = templateLibrary.generateZones(from: template, displayID: displayID, displaySize: displaySize)

        XCTAssertEqual(zones.count, 2)
        XCTAssertEqual(zones[0].bounds.width, 960)

        // 3. Create layout from template
        let display = Display(
            displayID: displayID,
            name: "Test Display",
            resolution: displaySize,
            position: .zero,
            isPrimary: true
        )

        let layout = Layout(
            layoutName: "Template Test Layout",
            layoutType: .zonesOnly,
            monitorConfiguration: MonitorConfiguration(displays: [display]),
            zones: zones
        )

        // 4. Save and verify
        XCTAssertNoThrow(try fileManager.saveLayout(layout))

        // Cleanup
        try? fileManager.deleteLayout(id: layout.id)
    }

    // MARK: - Preferences Integration Tests

    func testPreferencesIntegration() {
        let prefsManager = PreferencesManager.shared

        // Save current values
        let originalModifier = prefsManager.modifierKey
        let originalOpacity = prefsManager.overlayOpacity

        // Change preferences
        prefsManager.modifierKey = .option
        prefsManager.overlayOpacity = 0.5

        // Verify changes
        XCTAssertEqual(prefsManager.modifierKey, .option)
        XCTAssertEqual(prefsManager.overlayOpacity, 0.5)

        // Restore original values
        prefsManager.modifierKey = originalModifier
        prefsManager.overlayOpacity = originalOpacity
    }

    // MARK: - Monitor Configuration Tests

    func testMonitorConfigurationCompatibility() {
        let display1 = Display(
            displayID: "display-1",
            name: "Display 1",
            resolution: CGSize(width: 1920, height: 1080),
            position: .zero,
            isPrimary: true
        )

        let config1 = MonitorConfiguration(displays: [display1])
        let config2 = MonitorConfiguration(displays: [display1])

        XCTAssertTrue(config1.isCompatible(with: config2))
        XCTAssertTrue(config1.isSimilar(to: config2))
    }

    // MARK: - Error Handling Tests

    func testErrorHandling() {
        let fileManager = LayoutFileManager.shared

        // Try to load non-existent layout
        XCTAssertThrowsError(try fileManager.loadLayout(id: UUID())) { error in
            XCTAssertTrue(error is FileManagerError)
        }

        // Try to delete non-existent layout
        XCTAssertThrowsError(try fileManager.deleteLayout(id: UUID())) { error in
            XCTAssertTrue(error is FileManagerError)
        }
    }

    // MARK: - Layout Limit Tests

    func testLayoutLimitEnforcement() {
        let fileManager = LayoutFileManager.shared

        // Get current count
        let initialLayouts = (try? fileManager.listLayouts()) ?? []
        let slotsAvailable = 10 - initialLayouts.count

        // Create layouts up to limit
        var createdLayouts: [Layout] = []

        for i in 0..<slotsAvailable {
            let layout = createTestLayout(name: "Limit Test \(i)")
            XCTAssertNoThrow(try fileManager.saveLayout(layout))
            createdLayouts.append(layout)
        }

        // Try to create one more (should fail)
        let extraLayout = createTestLayout(name: "Extra Layout")
        XCTAssertThrowsError(try fileManager.saveLayout(extraLayout))

        // Cleanup
        for layout in createdLayouts {
            try? fileManager.deleteLayout(id: layout.id)
        }
    }

    // MARK: - Helper Methods

    private func createTestLayout(name: String) -> Layout {
        let display = Display(
            displayID: "test-display",
            name: "Test Display",
            resolution: CGSize(width: 1920, height: 1080),
            position: .zero,
            isPrimary: true
        )

        let zone = Zone(
            zoneNumber: 1,
            displayID: "test-display",
            bounds: CGRect(x: 0, y: 0, width: 1920, height: 1080)
        )

        return Layout(
            layoutName: name,
            layoutType: .zonesOnly,
            monitorConfiguration: MonitorConfiguration(displays: [display]),
            zones: [zone]
        )
    }

    // MARK: - Cleanup

    override func tearDown() {
        // Clean up test layouts
        let fileManager = LayoutFileManager.shared
        let layouts = (try? fileManager.listLayouts()) ?? []

        for layout in layouts where layout.layoutName.contains("Test") {
            try? fileManager.deleteLayout(id: layout.id)
        }
    }
}

// MARK: - Manual Testing Checklist

/*
 Manual Testing Checklist:

 ✅ Platform Testing:
 - [ ] Test on Apple Silicon Mac
 - [ ] Test on Intel Mac
 - [ ] Test on macOS 11.0 (Big Sur)
 - [ ] Test on macOS 12.0 (Monterey)
 - [ ] Test on macOS 13.0 (Ventura)
 - [ ] Test on macOS 14.0 (Sonoma)

 ✅ Monitor Configurations:
 - [ ] Single display (laptop)
 - [ ] Two displays (horizontal)
 - [ ] Two displays (vertical)
 - [ ] Three+ displays
 - [ ] Mixed resolution displays
 - [ ] Retina display
 - [ ] Non-Retina display
 - [ ] Display rotation
 - [ ] Hot-plug display (connect while running)
 - [ ] Hot-unplug display (disconnect while running)

 ✅ Window Snapping:
 - [ ] Snap window with Command key
 - [ ] Snap window with Option key
 - [ ] Snap window with Control key
 - [ ] Snap window with Shift key
 - [ ] Snap to all zones in layout
 - [ ] Snap with animation
 - [ ] Snap without animation
 - [ ] Snap windows of different apps (Safari, Finder, etc.)
 - [ ] Snap minimized window
 - [ ] Snap full-screen window (should fail gracefully)

 ✅ Zone Overlay:
 - [ ] Overlay appears on modifier key press
 - [ ] Overlay hides on modifier key release
 - [ ] Overlay shows on all displays
 - [ ] Zone highlighting works correctly
 - [ ] Zone numbers visible/hidden based on preference
 - [ ] Overlay opacity adjustable
 - [ ] Smooth animations

 ✅ Layout Management:
 - [ ] Create new layout
 - [ ] Edit layout name
 - [ ] Duplicate layout
 - [ ] Delete layout (with confirmation)
 - [ ] Switch between layout types
 - [ ] Activate layout
 - [ ] Layout limit enforcement (10 max)
 - [ ] Layout persistence across app restarts

 ✅ App Restoration:
 - [ ] Restore apps that are running
 - [ ] Launch and restore apps that aren't running
 - [ ] Handle app not found
 - [ ] Handle app launch failure
 - [ ] Handle app unresponsive
 - [ ] Progress notification
 - [ ] Completion notification

 ✅ Keyboard Shortcuts:
 - [ ] Cmd+Opt+1-0 switch layouts
 - [ ] Cmd+Opt+Shift+L layout picker
 - [ ] Cmd+Comma open preferences
 - [ ] All shortcuts work without conflicts

 ✅ Permissions:
 - [ ] First-run setup wizard
 - [ ] Accessibility permission request
 - [ ] Screen Recording permission request
 - [ ] Permission reminder when missing
 - [ ] Graceful degradation without permissions

 ✅ Preferences:
 - [ ] All settings persist across restarts
 - [ ] iCloud sync (if enabled)
 - [ ] Reset to defaults works
 - [ ] Settings apply immediately

 ✅ Error Handling:
 - [ ] File not found errors
 - [ ] Permission denied errors
 - [ ] Corrupted layout files
 - [ ] Full disk scenarios
 - [ ] Network interruptions (iCloud)
 - [ ] User-friendly error messages

 ✅ Accessibility:
 - [ ] VoiceOver navigation works
 - [ ] Keyboard navigation complete
 - [ ] Reduce Motion respected
 - [ ] Increase Contrast respected
 - [ ] Reduce Transparency respected
 - [ ] All controls keyboard accessible

 ✅ Performance:
 - [ ] App launches in < 1 second
 - [ ] Zone detection < 1ms
 - [ ] Overlay displays in < 100ms
 - [ ] Window snapping starts in < 10ms
 - [ ] Memory usage < 100MB active
 - [ ] No memory leaks after extended use
 - [ ] CPU usage < 5% when idle
 - [ ] CPU usage reasonable during snapping

 ✅ Edge Cases:
 - [ ] Very large displays (5K, 6K)
 - [ ] Very small displays (< 1280x720)
 - [ ] Ultrawide displays (21:9, 32:9)
 - [ ] Portrait orientation displays
 - [ ] Apps with minimum window sizes
 - [ ] Apps that resist resizing
 - [ ] Split View / Spaces compatibility
 - [ ] Mission Control compatibility
 - [ ] Multiple virtual desktops
 */
