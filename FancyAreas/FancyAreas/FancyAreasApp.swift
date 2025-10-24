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
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide the app from the Dock (menu bar only app)
        NSApp.setActivationPolicy(.accessory)

        // Set up menu bar icon
        setupMenuBar()

        print("FancyAreas launched successfully")
    }

    func applicationWillTerminate(_ notification: Notification) {
        print("FancyAreas terminating")
    }

    /// Set up the menu bar status item and menu
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            // TODO: Replace with actual app icon
            button.image = NSImage(systemSymbolName: "square.grid.2x2", accessibilityDescription: "FancyAreas")
            button.image?.isTemplate = true
        }

        // Create menu
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "No layouts available", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "New Layout...", action: #selector(newLayout), keyEquivalent: "n"))
        menu.addItem(NSMenuItem(title: "Edit Layouts...", action: #selector(editLayouts), keyEquivalent: "e"))
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(openPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit FancyAreas", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    @objc func newLayout() {
        print("New Layout clicked")
        // TODO: Implement layout creation
    }

    @objc func editLayouts() {
        print("Edit Layouts clicked")
        // TODO: Implement layout editing
    }

    @objc func openPreferences() {
        print("Preferences clicked")
        // TODO: Implement preferences window
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
