//
//  AccessibilityHelper.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import Foundation
import AppKit

/// Helper utilities for accessibility features
class AccessibilityHelper {

    static let shared = AccessibilityHelper()

    private init() {}

    // MARK: - System Accessibility Settings

    /// Checks if Reduce Motion is enabled
    var isReduceMotionEnabled: Bool {
        return NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
    }

    /// Checks if Increase Contrast is enabled
    var isIncreaseContrastEnabled: Bool {
        return NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast
    }

    /// Checks if Reduce Transparency is enabled
    var isReduceTransparencyEnabled: Bool {
        return NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency
    }

    /// Checks if Differentiate Without Color is enabled
    var isDifferentiateWithoutColorEnabled: Bool {
        return NSWorkspace.shared.accessibilityDisplayShouldDifferentiateWithoutColor
    }

    // MARK: - Accessibility Labels

    /// Creates an accessibility label for a zone
    /// - Parameters:
    ///   - zone: The zone
    ///   - layoutName: The layout name
    /// - Returns: Formatted accessibility label
    func labelForZone(_ zone: Zone, layoutName: String) -> String {
        var label = "Zone \(zone.zoneNumber) in \(layoutName)"

        if let app = zone.assignedApp {
            label += ", assigned to \(app.appName)"
        }

        let width = Int(zone.bounds.width)
        let height = Int(zone.bounds.height)
        label += ", size \(width) by \(height) pixels"

        return label
    }

    /// Creates an accessibility label for a layout
    /// - Parameter layout: The layout
    /// - Returns: Formatted accessibility label
    func labelForLayout(_ layout: Layout) -> String {
        var label = layout.layoutName

        label += ", \(layout.zones.count) zones"

        switch layout.layoutType {
        case .zonesOnly:
            label += ", zones only"
        case .zonesAndApps:
            let assignedCount = layout.zones.filter { $0.assignedApp != nil }.count
            label += ", \(assignedCount) apps assigned"
        }

        if layout.monitorConfiguration.displayCount > 1 {
            label += ", \(layout.monitorConfiguration.displayCount) displays"
        }

        return label
    }

    /// Creates an accessibility hint
    /// - Parameters:
    ///   - action: The action description
    ///   - context: Additional context
    /// - Returns: Formatted hint
    func hint(action: String, context: String? = nil) -> String {
        var hint = action
        if let context = context {
            hint += ". \(context)"
        }
        return hint
    }

    // MARK: - Keyboard Navigation Support

    /// Announces a message to VoiceOver
    /// - Parameter message: The message to announce
    func announce(_ message: String) {
        NSAccessibility.post(
            element: NSApp.mainWindow ?? NSApp,
            notification: .announcementRequested,
            userInfo: [.announcement: message, .priority: NSAccessibilityPriorityLevel.high]
        )
    }

    /// Announces layout activation
    /// - Parameter layoutName: The activated layout name
    func announceLayoutActivation(_ layoutName: String) {
        announce("Layout '\(layoutName)' activated")
    }

    /// Announces zone detection
    /// - Parameter zoneNumber: The detected zone number
    func announceZoneDetection(_ zoneNumber: Int) {
        announce("Entered zone \(zoneNumber)")
    }

    /// Announces app restoration progress
    /// - Parameters:
    ///   - current: Current app number
    ///   - total: Total number of apps
    func announceRestorationProgress(current: Int, total: Int) {
        announce("Restoring app \(current) of \(total)")
    }
}

// MARK: - View Extensions for Accessibility

extension NSView {

    /// Configures accessibility for a zone preview
    /// - Parameters:
    ///   - zone: The zone
    ///   - layoutName: The layout name
    func configureZoneAccessibility(_ zone: Zone, layoutName: String) {
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        setAccessibilityLabel(AccessibilityHelper.shared.labelForZone(zone, layoutName: layoutName))
        setAccessibilityHelp("Double-click to edit zone properties")
    }

    /// Configures accessibility for a layout row
    /// - Parameter layout: The layout
    func configureLayoutAccessibility(_ layout: Layout) {
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        setAccessibilityLabel(AccessibilityHelper.shared.labelForLayout(layout))
        setAccessibilityHelp("Double-click to activate layout")
    }
}

// MARK: - Accessible Colors

extension AccessibilityHelper {

    /// Gets an accessible color based on system settings
    /// - Parameters:
    ///   - baseColor: The base color
    ///   - purpose: The purpose of the color
    /// - Returns: Adjusted color for accessibility
    func accessibleColor(_ baseColor: NSColor, purpose: ColorPurpose) -> NSColor {
        var color = baseColor

        // Increase contrast if needed
        if isIncreaseContrastEnabled {
            switch purpose {
            case .zoneOverlay:
                color = color.withAlphaComponent(min(baseColor.alphaComponent * 1.5, 1.0))
            case .highlight:
                color = color.withBrightness(0.8)
            case .text:
                color = .labelColor
            case .background:
                color = .windowBackgroundColor
            }
        }

        // Adjust for differentiate without color
        if isDifferentiateWithoutColorEnabled && purpose == .highlight {
            // Use patterns or shapes instead of just color
            // This would need additional UI work
        }

        return color
    }

    /// Gets overlay opacity respecting accessibility settings
    /// - Parameter baseOpacity: The base opacity
    /// - Returns: Adjusted opacity
    func accessibleOverlayOpacity(_ baseOpacity: CGFloat) -> CGFloat {
        if isReduceTransparencyEnabled {
            return min(baseOpacity * 1.5, 0.9)
        }
        return baseOpacity
    }
}

// MARK: - Color Purpose

enum ColorPurpose {
    case zoneOverlay
    case highlight
    case text
    case background
}

// MARK: - NSColor Extensions

extension NSColor {

    func withBrightness(_ brightness: CGFloat) -> NSColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var currentBrightness: CGFloat = 0
        var alpha: CGFloat = 0

        getHue(&hue, saturation: &saturation, brightness: &currentBrightness, alpha: &alpha)

        return NSColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
}

// MARK: - Keyboard Navigation Documentation

/*
 Keyboard Navigation Support:

 Menu Bar:
 - Cmd+Comma: Open Preferences
 - Cmd+N: New Layout (when in Layout Management)
 - Cmd+W: Close Window

 Layout Switching:
 - Cmd+Opt+1-0: Switch to layout 1-10
 - Cmd+Opt+Shift+L: Open layout picker

 Layout Management:
 - Tab: Navigate between controls
 - Space/Enter: Activate selected item
 - Delete: Delete selected layout (with confirmation)
 - Cmd+D: Duplicate selected layout

 Preferences:
 - Tab: Navigate between settings
 - Space: Toggle checkboxes
 - Arrow keys: Adjust sliders and pickers

 VoiceOver Support:
 - All interactive elements have labels
 - All actions have hints
 - State changes are announced
 - Progress is announced during operations
 */
