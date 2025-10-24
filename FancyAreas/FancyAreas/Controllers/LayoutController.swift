//
//  LayoutController.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import Foundation
import AppKit

/// Manages layout activation and deactivation
/// Coordinates between layout files, zone manager, and UI
class LayoutController {

    // MARK: - Properties

    static let shared = LayoutController()

    private let zoneManager = ZoneManager.shared
    private let fileManager = LayoutFileManager.shared
    private let menuBarController: MenuBarController?

    @Published private(set) var activeLayout: Layout?
    @Published private(set) var isLayoutActive: Bool = false

    // MARK: - Initialization

    private init() {
        menuBarController = nil // Will be set externally if needed
    }

    // MARK: - Public Methods

    /// Activates a layout by ID
    /// - Parameter layoutID: The UUID of the layout to activate
    /// - Returns: True if activation was successful
    @discardableResult
    func activateLayout(id layoutID: UUID) -> Bool {
        do {
            let layout = try fileManager.loadLayout(id: layoutID)
            return activateLayout(layout)
        } catch {
            print("⚠️ Failed to load layout: \(error)")
            showError(title: "Layout Activation Failed", message: "Could not load layout: \(error.localizedDescription)")
            return false
        }
    }

    /// Activates a layout
    /// - Parameter layout: The layout to activate
    /// - Returns: True if activation was successful
    @discardableResult
    func activateLayout(_ layout: Layout) -> Bool {
        // Check current monitor configuration
        let currentConfig = MonitorManager.shared.getCurrentConfiguration()

        // Check compatibility
        if !layout.monitorConfiguration.isCompatible(with: currentConfig) {
            if !layout.monitorConfiguration.isSimilar(to: currentConfig) {
                // Show warning but allow activation
                let shouldContinue = showConfigMismatchWarning(layout: layout, currentConfig: currentConfig)
                if !shouldContinue {
                    return false
                }
            }
        }

        // Activate zones in ZoneManager
        zoneManager.activateLayout(layout)

        // Update state
        activeLayout = layout
        isLayoutActive = true

        // Save as last active layout
        UserDefaults.standard.set(layout.id.uuidString, forKey: "lastActiveLayoutID")

        // Notify menu bar
        NotificationCenter.default.post(name: .layoutActivated, object: layout)

        print("✓ Layout '\(layout.layoutName)' activated")
        return true
    }

    /// Deactivates the current layout
    func deactivateLayout() {
        zoneManager.deactivateLayout()
        activeLayout = nil
        isLayoutActive = false

        UserDefaults.standard.removeObject(forKey: "lastActiveLayoutID")

        NotificationCenter.default.post(name: .layoutDeactivated, object: nil)

        print("✓ Layout deactivated")
    }

    /// Restores the last active layout (called on app launch)
    func restoreLastActiveLayout() {
        guard let layoutIDString = UserDefaults.standard.string(forKey: "lastActiveLayoutID"),
              let layoutID = UUID(uuidString: layoutIDString) else {
            print("No last active layout to restore")
            return
        }

        print("Restoring last active layout...")
        activateLayout(id: layoutID)
    }

    // MARK: - Private Methods

    /// Shows a warning dialog when monitor configuration doesn't match
    /// - Parameters:
    ///   - layout: The layout being activated
    ///   - currentConfig: The current monitor configuration
    /// - Returns: True if user wants to continue, false otherwise
    private func showConfigMismatchWarning(layout: Layout, currentConfig: MonitorConfiguration) -> Bool {
        let alert = NSAlert()
        alert.messageText = "Monitor Configuration Mismatch"
        alert.informativeText = """
        This layout was created for a different monitor configuration.

        Layout: \(layout.monitorConfiguration.displayCount) display(s)
        Current: \(currentConfig.displayCount) display(s)

        The layout may not work as expected. Continue anyway?
        """
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Continue")
        alert.addButton(withTitle: "Cancel")

        return alert.runModal() == .alertFirstButtonReturn
    }

    /// Shows an error alert
    /// - Parameters:
    ///   - title: Alert title
    ///   - message: Alert message
    private func showError(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}

// MARK: - Monitor Manager

/// Manages monitor detection and configuration
class MonitorManager {

    static let shared = MonitorManager()

    private init() {
        setupMonitorChangeNotifications()
    }

    /// Gets the current monitor configuration
    /// - Returns: Current MonitorConfiguration
    func getCurrentConfiguration() -> MonitorConfiguration {
        var displays: [Display] = []

        for (index, screen) in NSScreen.screens.enumerated() {
            let displayID = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID ?? 0
            let isPrimary = (screen == NSScreen.main)

            let display = Display(
                displayID: String(displayID),
                name: "Display \(index + 1)",
                resolution: screen.frame.size,
                position: screen.frame.origin,
                isPrimary: isPrimary
            )

            displays.append(display)
        }

        return MonitorConfiguration(displays: displays)
    }

    /// Sets up notifications for monitor configuration changes
    private func setupMonitorChangeNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    @objc private func screenParametersChanged(_ notification: Notification) {
        print("🖥️ Screen parameters changed")

        // Notify that monitors have changed
        NotificationCenter.default.post(name: .monitorConfigurationChanged, object: nil)

        // Check if active layout is still compatible
        if let activeLayout = LayoutController.shared.activeLayout {
            let currentConfig = getCurrentConfiguration()
            if !activeLayout.monitorConfiguration.isCompatible(with: currentConfig) {
                print("⚠️ Active layout no longer compatible with monitor configuration")
                // Could show a notification here
            }
        }
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let layoutActivated = Notification.Name("layoutActivated")
    static let layoutDeactivated = Notification.Name("layoutDeactivated")
    static let monitorConfigurationChanged = Notification.Name("monitorConfigurationChanged")
}
