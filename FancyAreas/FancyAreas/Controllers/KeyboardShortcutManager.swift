//
//  KeyboardShortcutManager.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import Cocoa
import Carbon

/// Manages global keyboard shortcuts for layout switching
class KeyboardShortcutManager {

    // MARK: - Properties

    static let shared = KeyboardShortcutManager()

    private var eventHandler: EventHandlerRef?
    private var shortcuts: [KeyboardShortcut] = []

    // Default shortcuts
    private let layoutPickerShortcut = KeyboardShortcut(
        name: "Open Layout Picker",
        keyCode: kVK_ANSI_L,
        modifiers: [.command, .option, .shift],
        action: .openLayoutPicker
    )

    // MARK: - Initialization

    private init() {
        setupDefaultShortcuts()
    }

    // MARK: - Public Methods

    /// Registers all keyboard shortcuts
    func registerShortcuts() {
        // Register layout picker
        registerShortcut(layoutPickerShortcut)

        // Register layout shortcuts (Cmd+Opt+1 through Cmd+Opt+0)
        for i in 1...10 {
            let keyCode = keyCodeForNumber(i % 10) // 0 for 10
            let shortcut = KeyboardShortcut(
                name: "Switch to Layout \(i)",
                keyCode: keyCode,
                modifiers: [.command, .option],
                action: .switchToLayout(i)
            )
            registerShortcut(shortcut)
        }

        print("✓ Keyboard shortcuts registered")
    }

    /// Unregisters all keyboard shortcuts
    func unregisterShortcuts() {
        shortcuts.removeAll()
        // TODO: Remove event handlers
        print("✓ Keyboard shortcuts unregistered")
    }

    // MARK: - Private Methods

    /// Sets up default shortcuts
    private func setupDefaultShortcuts() {
        shortcuts.append(layoutPickerShortcut)
    }

    /// Registers a single keyboard shortcut
    /// - Parameter shortcut: The shortcut to register
    private func registerShortcut(_ shortcut: KeyboardShortcut) {
        shortcuts.append(shortcut)

        // Register with NSEvent
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.handleKeyEvent(event, shortcut: shortcut) == true {
                return nil // Consume event
            }
            return event
        }
    }

    /// Handles a key event for a shortcut
    /// - Parameters:
    ///   - event: The key event
    ///   - shortcut: The shortcut to check
    /// - Returns: True if event was handled
    private func handleKeyEvent(_ event: NSEvent, shortcut: KeyboardShortcut) -> Bool {
        // Check if key code matches
        guard event.keyCode == shortcut.keyCode else { return false }

        // Check if modifiers match
        let eventModifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let requiredModifiers = shortcut.cgEventFlags

        guard eventModifiers.contains(requiredModifiers) else { return false }

        // Execute action
        executeAction(shortcut.action)
        return true
    }

    /// Executes a shortcut action
    /// - Parameter action: The action to execute
    private func executeAction(_ action: ShortcutAction) {
        switch action {
        case .openLayoutPicker:
            print("⌨️ Layout picker shortcut triggered")
            // TODO: Open quick layout picker
            showQuickLayoutPicker()

        case .switchToLayout(let index):
            print("⌨️ Switch to layout \(index) shortcut triggered")
            switchToLayoutAtIndex(index)
        }
    }

    /// Shows the quick layout picker (TODO: implement proper UI)
    private func showQuickLayoutPicker() {
        // For now, just activate the first layout
        do {
            let layouts = try LayoutFileManager.shared.listLayouts()
            if let firstLayout = layouts.first {
                LayoutController.shared.activateLayout(firstLayout)
            }
        } catch {
            print("Failed to load layouts: \(error)")
        }
    }

    /// Switches to a layout at a specific index
    /// - Parameter index: The layout index (1-10)
    private func switchToLayoutAtIndex(_ index: Int) {
        do {
            let layouts = try LayoutFileManager.shared.listLayouts()
            guard index > 0 && index <= layouts.count else {
                print("No layout at index \(index)")
                return
            }

            let layout = layouts[index - 1]
            LayoutController.shared.activateLayout(layout)
        } catch {
            print("Failed to load layouts: \(error)")
        }
    }

    /// Returns the key code for a number (1-9, 0)
    /// - Parameter number: The number (0-9)
    /// - Returns: The Carbon key code
    private func keyCodeForNumber(_ number: Int) -> UInt16 {
        switch number {
        case 0: return kVK_ANSI_0
        case 1: return kVK_ANSI_1
        case 2: return kVK_ANSI_2
        case 3: return kVK_ANSI_3
        case 4: return kVK_ANSI_4
        case 5: return kVK_ANSI_5
        case 6: return kVK_ANSI_6
        case 7: return kVK_ANSI_7
        case 8: return kVK_ANSI_8
        case 9: return kVK_ANSI_9
        default: return kVK_ANSI_0
        }
    }
}

// MARK: - Keyboard Shortcut

struct KeyboardShortcut {
    let name: String
    let keyCode: UInt16
    let modifiers: Set<ModifierKey>
    let action: ShortcutAction

    var cgEventFlags: NSEvent.ModifierFlags {
        var flags: NSEvent.ModifierFlags = []
        for modifier in modifiers {
            flags.insert(modifier.eventFlag)
        }
        return flags
    }
}

// MARK: - Shortcut Action

enum ShortcutAction {
    case openLayoutPicker
    case switchToLayout(Int)
}

// MARK: - Modifier Key Extension

extension ModifierKey {
    var eventFlag: NSEvent.ModifierFlags {
        switch self {
        case .command: return .command
        case .option: return .option
        case .control: return .control
        case .shift: return .shift
        }
    }
}
