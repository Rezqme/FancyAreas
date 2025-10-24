//
//  FancyAreasApp.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import SwiftUI

/// Main application entry point for FancyAreas
/// A macOS window management application that enables zone-based window snapping
@main
struct FancyAreasApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

/// Application delegate handling app lifecycle and menu bar integration
class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarController: MenuBarController?
    var windowSnapController: WindowSnapController?
    var firstRunWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide the app from the Dock (menu bar only app)
        NSApp.setActivationPolicy(.accessory)

        // Set up menu bar icon with controller
        menuBarController = MenuBarController()

        // Check if first run
        let hasCompletedFirstRun = UserDefaults.standard.bool(forKey: "hasCompletedFirstRun")

        if !hasCompletedFirstRun {
            showFirstRunSetup()
        } else {
            // Check permissions and show reminder if needed
            let permissionsManager = PermissionsManager.shared
            let permissions = permissionsManager.checkAllPermissions()

            if !permissionsManager.getMissingPermissions().isEmpty {
                // Show reminder after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    permissionsManager.showPermissionReminder()
                }
            }

            // Start window snap controller if permissions granted
            if permissions[.accessibility] == true {
                startWindowSnapController()

                // Register keyboard shortcuts
                KeyboardShortcutManager.shared.registerShortcuts()

                // Restore last active layout
                LayoutController.shared.restoreLastActiveLayout()
            }
        }

        print("FancyAreas launched successfully")
    }

    func applicationWillTerminate(_ notification: Notification) {
        windowSnapController?.stop()
        print("FancyAreas terminating")
    }

    /// Starts the window snap controller
    private func startWindowSnapController() {
        windowSnapController = WindowSnapController.shared
        windowSnapController?.start()
        print("✓ Window snapping enabled")
    }


    /// Shows the first-run setup window
    func showFirstRunSetup() {
        let setupView = FirstRunSetupView()
        let hostingController = NSHostingController(rootView: setupView)

        firstRunWindow = NSWindow(contentViewController: hostingController)
        firstRunWindow?.title = "FancyAreas Setup"
        firstRunWindow?.styleMask = [.titled, .closable]
        firstRunWindow?.center()
        firstRunWindow?.makeKeyAndOrderFront(nil)

        NSApp.activate(ignoringOtherApps: true)
    }
}
