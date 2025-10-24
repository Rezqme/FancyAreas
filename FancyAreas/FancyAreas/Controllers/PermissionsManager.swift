//
//  PermissionsManager.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import Foundation
import AppKit
import ApplicationServices

/// Manages system permissions required by FancyAreas
/// Handles Accessibility, Screen Recording, and Automation permissions
class PermissionsManager: ObservableObject {

    // MARK: - Properties

    static let shared = PermissionsManager()

    @Published var hasAccessibilityPermission = false
    @Published var hasScreenRecordingPermission = false

    // MARK: - Permission Checking

    /// Checks if Accessibility permission is granted
    /// - Returns: True if permission is granted
    func checkAccessibilityPermission() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: false]
        let hasPermission = AXIsProcessTrustedWithOptions(options)

        DispatchQueue.main.async {
            self.hasAccessibilityPermission = hasPermission
        }

        return hasPermission
    }

    /// Checks if Screen Recording permission is granted
    /// - Returns: True if permission is granted
    func checkScreenRecordingPermission() -> Bool {
        // Screen recording permission is checked by attempting to access screen content
        // This is a simplified check
        if #available(macOS 10.15, *) {
            guard let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] else {
                DispatchQueue.main.async {
                    self.hasScreenRecordingPermission = false
                }
                return false
            }

            // If we can see window names, we have screen recording permission
            let hasPermission = windows.contains { window in
                window[kCGWindowName as String] != nil
            }

            DispatchQueue.main.async {
                self.hasScreenRecordingPermission = hasPermission
            }

            return hasPermission
        }

        return true // Older macOS versions don't require this permission
    }

    /// Checks all required permissions
    /// - Returns: Dictionary of permission statuses
    func checkAllPermissions() -> [Permission: Bool] {
        return [
            .accessibility: checkAccessibilityPermission(),
            .screenRecording: checkScreenRecordingPermission()
        ]
    }

    // MARK: - Permission Requesting

    /// Requests Accessibility permission with prompt
    func requestAccessibilityPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true]
        let _ = AXIsProcessTrustedWithOptions(options)

        // Show explanation dialog
        showPermissionExplanation(for: .accessibility)
    }

    /// Requests Screen Recording permission
    func requestScreenRecordingPermission() {
        // Trigger the system permission prompt by attempting to capture screen
        if #available(macOS 10.15, *) {
            _ = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID)
        }

        // Show explanation dialog
        showPermissionExplanation(for: .screenRecording)
    }

    /// Opens System Preferences to the appropriate permissions pane
    /// - Parameter permission: The permission to configure
    func openSystemPreferences(for permission: Permission) {
        let prefPath: String

        switch permission {
        case .accessibility:
            prefPath = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        case .screenRecording:
            prefPath = "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"
        case .automation:
            prefPath = "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation"
        }

        if let url = URL(string: prefPath) {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - User Interface

    /// Shows an explanation dialog for why a permission is needed
    /// - Parameter permission: The permission to explain
    func showPermissionExplanation(for permission: Permission) {
        let alert = NSAlert()
        alert.messageText = permission.title
        alert.informativeText = permission.explanation
        alert.alertStyle = .informational

        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Not Now")

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            openSystemPreferences(for: permission)
        }
    }

    /// Shows a reminder for missing permissions
    /// - Returns: True if user wants to grant permissions
    @discardableResult
    func showPermissionReminder() -> Bool {
        let missingPermissions = checkAllPermissions().filter { !$0.value }.keys

        guard !missingPermissions.isEmpty else { return true }

        let alert = NSAlert()
        alert.messageText = "Permissions Required"

        var permissionList = "FancyAreas needs the following permissions to function properly:\n\n"
        for permission in missingPermissions {
            permissionList += "• \(permission.title)\n  \(permission.shortExplanation)\n\n"
        }

        alert.informativeText = permissionList
        alert.alertStyle = .warning

        alert.addButton(withTitle: "Grant Permissions")
        alert.addButton(withTitle: "Continue Without Permissions")

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            // Request each missing permission
            for permission in missingPermissions {
                switch permission {
                case .accessibility:
                    requestAccessibilityPermission()
                case .screenRecording:
                    requestScreenRecordingPermission()
                case .automation:
                    // Automation permissions are granted per-app automatically
                    break
                }
            }
            return true
        }

        return false
    }

    /// Returns a list of missing permissions
    /// - Returns: Array of permission types that are not granted
    func getMissingPermissions() -> [Permission] {
        let statuses = checkAllPermissions()
        return statuses.filter { !$0.value }.keys.sorted { $0.title < $1.title }
    }

    /// Returns features that require specific permissions
    /// - Parameter permission: The permission to check
    /// - Returns: Array of feature descriptions
    func featuresRequiring(_ permission: Permission) -> [String] {
        switch permission {
        case .accessibility:
            return [
                "Detect window positions and movements",
                "Snap windows to defined zones",
                "Move and resize windows automatically",
                "Restore application layouts"
            ]
        case .screenRecording:
            return [
                "Display zone overlays on your screens",
                "Show visual feedback during window dragging",
                "Preview zone layouts in real-time"
            ]
        case .automation:
            return [
                "Launch applications automatically",
                "Control specific application windows",
                "Position apps in designated zones"
            ]
        }
    }
}

// MARK: - Permission Enum

enum Permission: CaseIterable {
    case accessibility
    case screenRecording
    case automation

    var title: String {
        switch self {
        case .accessibility:
            return "Accessibility Permission"
        case .screenRecording:
            return "Screen Recording Permission"
        case .automation:
            return "Automation Permission"
        }
    }

    var shortExplanation: String {
        switch self {
        case .accessibility:
            return "Required to control window positions and enable snapping"
        case .screenRecording:
            return "Required to display zone overlays on your displays"
        case .automation:
            return "Required to launch and position applications"
        }
    }

    var explanation: String {
        switch self {
        case .accessibility:
            return """
            FancyAreas needs Accessibility permission to:

            • Detect when you drag windows
            • Move and resize windows to snap to zones
            • Monitor window positions across your displays
            • Enable automatic window management

            Without this permission, FancyAreas cannot function. Your privacy is respected - FancyAreas only monitors window positions and does not capture screen content or keystrokes.

            Click "Open System Preferences" to grant this permission.
            """
        case .screenRecording:
            return """
            FancyAreas needs Screen Recording permission to:

            • Display semi-transparent zone overlays on your screens
            • Show visual feedback when dragging windows
            • Preview your zone layouts in real-time

            FancyAreas does not record your screen or capture screenshots. This permission is only used to display overlay windows on top of your desktop.

            Click "Open System Preferences" to grant this permission.
            """
        case .automation:
            return """
            FancyAreas needs Automation permission to:

            • Launch applications automatically
            • Position specific application windows in zones
            • Restore your saved workspace layouts

            This permission will be requested automatically when you assign applications to zones. You can grant it on a per-application basis.

            Click "Open System Preferences" to review automation permissions.
            """
        }
    }
}
