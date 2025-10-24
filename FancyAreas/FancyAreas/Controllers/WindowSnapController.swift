//
//  WindowSnapController.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import Cocoa
import ApplicationServices

/// Coordinates window dragging, zone detection, and overlay display
/// Acts as the bridge between WindowDragMonitor and ZoneManager
class WindowSnapController: WindowDragMonitorDelegate {

    // MARK: - Properties

    static let shared = WindowSnapController()

    private let dragMonitor = WindowDragMonitor.shared
    private let zoneManager = ZoneManager.shared
    private let overlayManager = ZoneOverlayManager.shared
    private let windowSnapper = WindowSnapper.shared

    private var currentZone: Zone?
    private var isOverlayVisible = false

    // Configuration
    private var modifierKeyRequired: CGEventFlags = .maskCommand // Default: Command key

    // MARK: - Initialization

    private init() {
        dragMonitor.delegate = self
    }

    // MARK: - Public Methods

    /// Starts the window snap controller
    func start() {
        dragMonitor.startMonitoring()
        print("✓ WindowSnapController started")
    }

    /// Stops the window snap controller
    func stop() {
        dragMonitor.stopMonitoring()
        hideOverlay()
        print("✓ WindowSnapController stopped")
    }

    /// Sets the required modifier key for triggering zone overlay
    /// - Parameter flags: The modifier flags required
    func setRequiredModifier(_ flags: CGEventFlags) {
        modifierKeyRequired = flags
    }

    // MARK: - WindowDragMonitorDelegate

    func windowDragBegan(window: AXUIElement, at location: CGPoint) {
        print("🪟 Window drag began at \(location)")

        // Check if we have an active layout
        guard zoneManager.hasActiveLayout else {
            print("⚠️ No active layout")
            return
        }
    }

    func windowDragMoved(window: AXUIElement, to location: CGPoint, modifierFlags: CGEventFlags) {
        // Check if required modifier is pressed
        let shouldShowOverlay = modifierFlags.contains(modifierKeyRequired)

        if shouldShowOverlay {
            if !isOverlayVisible {
                showOverlay()
            }

            // Detect which zone the cursor is in
            detectAndHighlightZone(at: location)
        } else {
            if isOverlayVisible {
                hideOverlay()
            }
        }
    }

    func windowDragModifiersChanged(window: AXUIElement, at location: CGPoint, modifierFlags: CGEventFlags) {
        print("⌨️ Modifiers changed: \(modifierFlags.modifierDescription)")

        let shouldShowOverlay = modifierFlags.contains(modifierKeyRequired)

        if shouldShowOverlay && !isOverlayVisible {
            showOverlay()
            detectAndHighlightZone(at: location)
        } else if !shouldShowOverlay && isOverlayVisible {
            hideOverlay()
        }
    }

    func windowDragEnded(window: AXUIElement, at location: CGPoint, modifierFlags: CGEventFlags) {
        print("🪟 Window drag ended at \(location)")

        // Check if we should snap the window to a zone
        let shouldSnap = modifierFlags.contains(modifierKeyRequired)

        if shouldSnap, let zone = currentZone {
            print("📍 Snapping window to zone \(zone.zoneNumber)")
            snapWindow(window, to: zone)
        }

        // Hide overlay
        hideOverlay()
        currentZone = nil
    }

    // MARK: - Private Methods

    /// Shows the zone overlay
    private func showOverlay() {
        guard !isOverlayVisible else { return }
        guard let layout = zoneManager.currentLayout else { return }

        overlayManager.show(layout: layout)
        isOverlayVisible = true
        print("👁️ Showing zone overlay")
    }

    /// Hides the zone overlay
    private func hideOverlay() {
        guard isOverlayVisible else { return }

        overlayManager.hide()
        isOverlayVisible = false
        currentZone = nil
        print("👁️ Hiding zone overlay")
    }

    /// Detects which zone contains the point and highlights it
    /// - Parameter location: The cursor location
    private func detectAndHighlightZone(at location: CGPoint) {
        // Get the display ID for this location
        // TODO: Implement proper multi-display support (Task 21)
        let displayID = "primary" // Placeholder

        let detectedZone = zoneManager.detectZone(at: location, on: displayID)

        if detectedZone?.id != currentZone?.id {
            currentZone = detectedZone

            // Update overlay highlight
            overlayManager.highlightZone(detectedZone)

            if let zone = detectedZone {
                print("📍 Entered zone \(zone.zoneNumber)")
            } else {
                print("📍 No zone at cursor")
            }
        }
    }

    /// Snaps a window to a zone
    /// - Parameters:
    ///   - window: The window to snap
    ///   - zone: The zone to snap to
    private func snapWindow(_ window: AXUIElement, to zone: Zone) {
        print("📏 Snapping window to zone \(zone.zoneNumber)")

        // Get window info for debugging
        let windowInfo = windowSnapper.getWindowInfo(window)
        if let title = windowInfo["title"] as? String {
            print("   Window: \(title)")
        }

        // Perform snap
        let success = windowSnapper.snapWindow(window, to: zone, animated: true)

        if success {
            print("✓ Window snapped successfully")
        } else {
            print("⚠️ Window snap failed")
        }
    }

    /// Gets the display ID for a point
    /// - Parameter point: The point in screen coordinates
    /// - Returns: The display ID, or nil
    private func getDisplayID(for point: CGPoint) -> String? {
        // TODO: Implement proper display detection (Task 21)
        return "primary"
    }
}
