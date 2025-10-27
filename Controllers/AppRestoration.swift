//
//  AppRestoration.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import Foundation
import Cocoa
import ApplicationServices

/// Handles application launching and positioning for "Zones + Apps" layouts
/// Non-destructive approach: only launches/positions assigned apps
class AppRestoration {

    // MARK: - Properties

    static let shared = AppRestoration()

    private let windowSnapper = WindowSnapper.shared
    private var restorationInProgress = false

    // MARK: - Public Methods

    /// Restores apps from a layout
    /// - Parameter layout: The layout containing app assignments
    func restoreApps(from layout: Layout) {
        guard layout.layoutType == .zonesAndApps else {
            print("⚠️ Layout is not zones+apps type")
            return
        }

        guard !restorationInProgress else {
            print("⚠️ Restoration already in progress")
            return
        }

        restorationInProgress = true

        // Get zones with assigned apps
        let zonesWithApps = layout.zones.filter { $0.assignedApp != nil }

        guard !zonesWithApps.isEmpty else {
            print("⚠️ No apps assigned to zones")
            restorationInProgress = false
            return
        }

        print("🚀 Restoring \(zonesWithApps.count) app(s)...")

        var successCount = 0
        var failureCount = 0

        // Process each zone with an assigned app
        for zone in zonesWithApps {
            guard let app = zone.assignedApp else { continue }

            if restoreApp(app, to: zone) {
                successCount += 1
            } else {
                failureCount += 1
            }
        }

        restorationInProgress = false

        // Show completion notification
        let message = "\(successCount) of \(zonesWithApps.count) apps restored"
        showNotification(title: "App Restoration Complete", message: message)

        if failureCount > 0 {
            print("⚠️ \(failureCount) app(s) failed to restore")
        }

        print("✓ App restoration complete")
    }

    // MARK: - Private Methods

    /// Restores a single app to a zone
    /// - Parameters:
    ///   - app: The assigned app
    ///   - zone: The target zone
    /// - Returns: True if successful
    private func restoreApp(_ app: AssignedApp, to zone: Zone) -> Bool {
        print("  Processing: \(app.appName)")

        // Check if app is running
        let runningApps = NSWorkspace.shared.runningApplications
        let targetApp = runningApps.first { $0.bundleIdentifier == app.bundleID }

        if let runningApp = targetApp {
            // App is running - position it
            return positionRunningApp(runningApp, to: zone, matchingTitle: app.windowTitle)
        } else {
            // App is not running - launch it
            return launchApp(app.bundleID, to: zone)
        }
    }

    /// Positions an already-running app to a zone
    /// - Parameters:
    ///   - app: The running application
    ///   - zone: The target zone
    ///   - windowTitle: Optional window title to match
    /// - Returns: True if successful
    private func positionRunningApp(_ app: NSRunningApplication, to zone: Zone, matchingTitle: String?) -> Bool {
        guard let pid = app.processIdentifier as pid_t? else { return false }

        let appElement = AXUIElementCreateApplication(pid)
        var windowsRef: CFTypeRef?

        // Get windows
        guard AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsRef) == .success,
              let windows = windowsRef as? [AXUIElement],
              !windows.isEmpty else {
            print("    ⚠️ No windows found")
            return false
        }

        // Find the right window (by title if specified, otherwise first window)
        let targetWindow: AXUIElement
        if let title = matchingTitle, !title.isEmpty {
            targetWindow = windows.first { window in
                var titleRef: CFTypeRef?
                guard AXUIElementCopyAttributeValue(window, kAXTitleAttribute as CFString, &titleRef) == .success,
                      let windowTitle = titleRef as? String else {
                    return false
                }
                return windowTitle.contains(title)
            } ?? windows.first!
        } else {
            targetWindow = windows.first!
        }

        // Snap window to zone
        windowSnapper.snapWindow(targetWindow, to: zone, animated: false)
        return true
    }

    /// Launches an app and positions it to a zone
    /// - Parameters:
    ///   - bundleID: The bundle identifier
    ///   - zone: The target zone
    /// - Returns: True if successful
    private func launchApp(_ bundleID: String, to zone: Zone) -> Bool {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            print("    ⚠️ App not found: \(bundleID)")
            return false
        }

        do {
            let app = try NSWorkspace.shared.launchApplication(
                at: appURL,
                options: [.withoutActivation],
                configuration: [:]
            )

            // Wait for app to launch (max 5 seconds)
            let startTime = Date()
            while Date().timeIntervalSince(startTime) < 5.0 {
                if app.isFinishedLaunching {
                    // App launched - position it
                    Thread.sleep(forTimeInterval: 0.5) // Give it a moment to create windows
                    return positionRunningApp(app, to: zone, matchingTitle: nil)
                }
                Thread.sleep(forTimeInterval: 0.1)
            }

            print("    ⚠️ App launch timeout")
            return false

        } catch {
            print("    ⚠️ Failed to launch: \(error.localizedDescription)")
            return false
        }
    }

    /// Shows a notification
    /// - Parameters:
    ///   - title: Notification title
    ///   - message: Notification message
    private func showNotification(title: String, message: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = message
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
}
