//
//  LaunchOnLoginManager.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import Foundation
import ServiceManagement

/// Manages the launch on login functionality
/// Uses modern ServiceManagement API for macOS 13+ and fallback for older versions
class LaunchOnLoginManager {

    // MARK: - Properties

    static let shared = LaunchOnLoginManager()

    private let launchOnLoginKey = "launchOnLogin"

    /// Current launch on login status
    var isEnabled: Bool {
        get {
            if #available(macOS 13.0, *) {
                return SMAppService.mainApp.status == .enabled
            } else {
                return UserDefaults.standard.bool(forKey: launchOnLoginKey)
            }
        }
        set {
            if newValue {
                enableLaunchOnLogin()
            } else {
                disableLaunchOnLogin()
            }
        }
    }

    // MARK: - Public Methods

    /// Enables launch on login
    func enableLaunchOnLogin() {
        if #available(macOS 13.0, *) {
            // Use modern ServiceManagement API
            do {
                try SMAppService.mainApp.register()
                UserDefaults.standard.set(true, forKey: launchOnLoginKey)
                print("✓ Launch on login enabled")
            } catch {
                print("⚠️ Failed to enable launch on login: \(error.localizedDescription)")
                showError(message: "Failed to enable launch on login: \(error.localizedDescription)")
            }
        } else {
            // Fallback for macOS 11-12
            #if compiler(>=5.5)
            if #available(macOS 11.0, *) {
                let success = SMLoginItemSetEnabled("com.fancyareas.app.LaunchHelper" as CFString, true)
                UserDefaults.standard.set(success, forKey: launchOnLoginKey)

                if success {
                    print("✓ Launch on login enabled (legacy)")
                } else {
                    print("⚠️ Failed to enable launch on login (legacy)")
                    showError(message: "Failed to enable launch on login. Please try again.")
                }
            }
            #endif
        }
    }

    /// Disables launch on login
    func disableLaunchOnLogin() {
        if #available(macOS 13.0, *) {
            // Use modern ServiceManagement API
            do {
                try SMAppService.mainApp.unregister()
                UserDefaults.standard.set(false, forKey: launchOnLoginKey)
                print("✓ Launch on login disabled")
            } catch {
                print("⚠️ Failed to disable launch on login: \(error.localizedDescription)")
                showError(message: "Failed to disable launch on login: \(error.localizedDescription)")
            }
        } else {
            // Fallback for macOS 11-12
            #if compiler(>=5.5)
            if #available(macOS 11.0, *) {
                let success = SMLoginItemSetEnabled("com.fancyareas.app.LaunchHelper" as CFString, false)
                UserDefaults.standard.set(false, forKey: launchOnLoginKey)

                if success {
                    print("✓ Launch on login disabled (legacy)")
                } else {
                    print("⚠️ Failed to disable launch on login (legacy)")
                }
            }
            #endif
        }
    }

    /// Checks the current launch on login status
    /// - Returns: True if enabled, false otherwise
    func checkStatus() -> Bool {
        if #available(macOS 13.0, *) {
            let status = SMAppService.mainApp.status
            return status == .enabled
        } else {
            return UserDefaults.standard.bool(forKey: launchOnLoginKey)
        }
    }

    /// Returns a description of the current status
    /// - Returns: Human-readable status string
    func statusDescription() -> String {
        if #available(macOS 13.0, *) {
            switch SMAppService.mainApp.status {
            case .enabled:
                return "Enabled - FancyAreas will launch when you log in"
            case .notRegistered:
                return "Disabled - FancyAreas will not launch automatically"
            case .requiresApproval:
                return "Requires Approval - Check System Preferences > General > Login Items"
            case .notFound:
                return "Error - Launch helper not found"
            @unknown default:
                return "Unknown status"
            }
        } else {
            return isEnabled ? "Enabled" : "Disabled"
        }
    }

    // MARK: - Private Methods

    /// Shows an error alert
    /// - Parameter message: The error message
    private func showError(message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Launch on Login Error"
            alert.informativeText = message
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}

// MARK: - ServiceManagement Extensions

@available(macOS 13.0, *)
extension SMAppService {
    /// Convenience accessor for the main app service
    static var mainApp: SMAppService {
        SMAppService.mainApp
    }
}
