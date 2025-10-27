//
//  LaunchOnLoginManager.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import Foundation
import ServiceManagement
import AppKit

/// Manages the launch on login functionality
/// Uses modern ServiceManagement API for macOS 13+ and fallback for older versions
class LaunchOnLoginManager: ObservableObject {

    // MARK: - Properties

    static let shared = LaunchOnLoginManager()

    private let launchOnLoginKey = "launchOnLogin"

    /// Current launch on login status
    @Published var isEnabled: Bool = false

    private init() {
        // Initialize from saved state
        self.isEnabled = UserDefaults.standard.bool(forKey: launchOnLoginKey)
    }

    /// Updates the launch on login status
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if enabled {
            enableLaunchOnLogin()
        } else {
            disableLaunchOnLogin()
        }
    }

    // MARK: - Public Methods

    /// Enables launch on login
    private func enableLaunchOnLogin() {
        if #available(macOS 13.0, *) {
            // Use modern ServiceManagement API
            do {
                try SMAppService.mainApp.register()
                UserDefaults.standard.set(true, forKey: launchOnLoginKey)
                print("✓ Launch on login enabled")
            } catch {
                print("⚠️ Failed to enable launch on login: \(error.localizedDescription)")
                UserDefaults.standard.set(false, forKey: launchOnLoginKey)
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
    private func disableLaunchOnLogin() {
        if #available(macOS 13.0, *) {
            // Use modern ServiceManagement API
            do {
                try SMAppService.mainApp.unregister()
                UserDefaults.standard.set(false, forKey: launchOnLoginKey)
                print("✓ Launch on login disabled")
            } catch {
                print("⚠️ Failed to disable launch on login: \(error.localizedDescription)")
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

    /// Refreshes the enabled status from system
    func refreshStatus() {
        if #available(macOS 13.0, *) {
            let status = SMAppService.mainApp.status
            let systemEnabled = (status == .enabled)
            if isEnabled != systemEnabled {
                isEnabled = systemEnabled
                UserDefaults.standard.set(systemEnabled, forKey: launchOnLoginKey)
            }
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
