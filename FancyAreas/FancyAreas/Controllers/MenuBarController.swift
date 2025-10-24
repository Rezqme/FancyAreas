//
//  MenuBarController.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import AppKit
import Combine

/// Manages the menu bar icon and dropdown menu
/// Dynamically updates menu with saved layouts
class MenuBarController: NSObject {

    // MARK: - Properties

    private var statusItem: NSStatusItem?
    private var cancellables = Set<AnyCancellable>()
    private var activeLayoutID: UUID?
    private var preferencesWindow: NSWindow?
    private var layoutManagementWindow: NSWindow?

    private let fileManager = LayoutFileManager.shared

    // Icon states
    private enum IconState {
        case normal
        case active
        case noLayout

        var imageName: String {
            switch self {
            case .normal:
                return "square.grid.2x2"
            case .active:
                return "square.grid.2x2.fill"
            case .noLayout:
                return "square.grid.2x2"
            }
        }
    }

    private var currentIconState: IconState = .noLayout {
        didSet {
            updateIcon()
        }
    }

    // MARK: - Initialization

    override init() {
        super.init()
        setupMenuBar()
    }

    // MARK: - Public Methods

    /// Sets the active layout
    /// - Parameter layoutID: The UUID of the active layout, or nil if none
    func setActiveLayout(_ layoutID: UUID?) {
        activeLayoutID = layoutID
        currentIconState = layoutID != nil ? .active : .noLayout
        updateMenu()
    }

    /// Refreshes the menu with current layouts
    func refreshMenu() {
        updateMenu()
    }

    // MARK: - Private Methods

    /// Sets up the menu bar status item
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: IconState.normal.imageName,
                                   accessibilityDescription: "FancyAreas")
            button.image?.isTemplate = true
        }

        updateMenu()
    }

    /// Updates the menu bar icon
    private func updateIcon() {
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: currentIconState.imageName,
                                   accessibilityDescription: "FancyAreas")
            button.image?.isTemplate = true
        }
    }

    /// Updates the menu with current layouts
    private func updateMenu() {
        let menu = NSMenu()

        // Load layouts
        do {
            let layouts = try fileManager.listLayouts()

            if layouts.isEmpty {
                // No layouts available
                let noLayoutsItem = NSMenuItem(title: "No layouts available",
                                              action: nil,
                                              keyEquivalent: "")
                noLayoutsItem.isEnabled = false
                menu.addItem(noLayoutsItem)
            } else {
                // Add layout items
                for (index, layout) in layouts.enumerated() {
                    let layoutItem = createLayoutMenuItem(layout: layout, index: index)
                    menu.addItem(layoutItem)
                }
            }
        } catch {
            let errorItem = NSMenuItem(title: "Error loading layouts",
                                      action: nil,
                                      keyEquivalent: "")
            errorItem.isEnabled = false
            menu.addItem(errorItem)
        }

        menu.addItem(NSMenuItem.separator())

        // Action items
        let newLayoutItem = NSMenuItem(title: "New Layout...",
                                      action: #selector(newLayout),
                                      keyEquivalent: "n")
        newLayoutItem.target = self
        menu.addItem(newLayoutItem)

        let editLayoutsItem = NSMenuItem(title: "Edit Layouts...",
                                        action: #selector(editLayouts),
                                        keyEquivalent: "e")
        editLayoutsItem.target = self
        menu.addItem(editLayoutsItem)

        let preferencesItem = NSMenuItem(title: "Preferences...",
                                        action: #selector(openPreferences),
                                        keyEquivalent: ",")
        preferencesItem.target = self
        menu.addItem(preferencesItem)

        menu.addItem(NSMenuItem.separator())

        // Quit item
        let quitItem = NSMenuItem(title: "Quit FancyAreas",
                                 action: #selector(quitApp),
                                 keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    /// Creates a menu item for a layout
    /// - Parameters:
    ///   - layout: The layout to create item for
    ///   - index: The index of the layout (for keyboard shortcut)
    /// - Returns: NSMenuItem configured for the layout
    private func createLayoutMenuItem(layout: Layout, index: Int) -> NSMenuItem {
        let item = NSMenuItem(title: layout.layoutName,
                             action: #selector(activateLayout(_:)),
                             keyEquivalent: index < 10 ? "\(index + 1)" : "")

        item.target = self
        item.representedObject = layout.id

        // Add checkmark if this is the active layout
        if layout.id == activeLayoutID {
            item.state = .on
        }

        // Add type badge as attributed string
        let attributedTitle = createAttributedTitle(for: layout)
        item.attributedTitle = attributedTitle

        // Keyboard shortcut modifier
        if index < 10 {
            item.keyEquivalentModifierMask = [.command, .option]
        }

        return item
    }

    /// Creates an attributed title with layout type and monitor count badges
    /// - Parameter layout: The layout
    /// - Returns: NSAttributedString with badges
    private func createAttributedTitle(for layout: Layout) -> NSAttributedString {
        let title = NSMutableAttributedString(string: layout.layoutName)

        // Add type badge
        let typeBadge: String
        switch layout.layoutType {
        case .zonesOnly:
            typeBadge = " ▢"
        case .zonesAndApps:
            typeBadge = " ▣"
        }

        let badgeString = NSAttributedString(
            string: typeBadge,
            attributes: [
                .foregroundColor: NSColor.secondaryLabelColor,
                .font: NSFont.systemFont(ofSize: 12)
            ]
        )
        title.append(badgeString)

        // Add monitor count badge
        let displayCount = layout.monitorConfiguration.displayCount
        if displayCount > 1 {
            let monitorBadge = NSAttributedString(
                string: " (\(displayCount) displays)",
                attributes: [
                    .foregroundColor: NSColor.tertiaryLabelColor,
                    .font: NSFont.systemFont(ofSize: 11)
                ]
            )
            title.append(monitorBadge)
        }

        return title
    }

    // MARK: - Actions

    @objc private func activateLayout(_ sender: NSMenuItem) {
        guard let layoutID = sender.representedObject as? UUID else { return }

        print("Activating layout: \(layoutID)")

        // TODO: Implement layout activation via LayoutController
        setActiveLayout(layoutID)

        // Show notification
        showNotification(title: "Layout Activated",
                        message: "'\(sender.title)' is now active")
    }

    @objc private func newLayout() {
        print("Creating new layout")

        // Check layout limit
        do {
            let layouts = try fileManager.listLayouts()
            if layouts.count >= 10 {
                showAlert(title: "Layout Limit Reached",
                         message: "You have reached the maximum of 10 layouts. Please delete a layout before creating a new one.")
                return
            }
        } catch {
            print("Error checking layouts: \(error)")
        }

        // TODO: Open layout editor for new layout
        showNotification(title: "New Layout",
                        message: "Layout editor coming soon...")
    }

    @objc private func editLayouts() {
        print("Opening layout management")

        // If window already exists, bring it to front
        if let window = layoutManagementWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // Create new layout management window
        let layoutView = LayoutManagementWindow()
        let hostingController = NSHostingController(rootView: layoutView)

        let window = NSWindow(contentViewController: hostingController)
        window.title = "Layout Management"
        window.styleMask = [.titled, .closable, .resizable]
        window.setContentSize(NSSize(width: 900, height: 600))
        window.center()
        window.makeKeyAndOrderFront(nil)

        // Store reference and set up cleanup
        layoutManagementWindow = window
        window.delegate = self

        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func openPreferences() {
        print("Opening preferences")

        // If window already exists, bring it to front
        if let window = preferencesWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // Create new preferences window
        let preferencesView = PreferencesView()
        let hostingController = NSHostingController(rootView: preferencesView)

        let window = NSWindow(contentViewController: hostingController)
        window.title = "FancyAreas Preferences"
        window.styleMask = [.titled, .closable]
        window.center()
        window.makeKeyAndOrderFront(nil)

        // Store reference and set up cleanup
        preferencesWindow = window
        window.delegate = self

        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Notifications

    /// Shows a macOS notification
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

    /// Shows an alert dialog
    /// - Parameters:
    ///   - title: Alert title
    ///   - message: Alert message
    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

// MARK: - NSWindowDelegate

extension MenuBarController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            if window == preferencesWindow {
                preferencesWindow = nil
            } else if window == layoutManagementWindow {
                layoutManagementWindow = nil
            }
        }
    }
}
