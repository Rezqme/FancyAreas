//
//  PreferencesManager.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import Foundation
import Combine
import CoreGraphics

/// Manages application preferences with UserDefaults and optional iCloud sync
class PreferencesManager: ObservableObject {

    // MARK: - Properties

    static let shared = PreferencesManager()

    private let defaults = UserDefaults.standard
    private let ubiquitousStore = NSUbiquitousKeyValueStore.default

    // Published properties for SwiftUI binding
    @Published var modifierKeys: Set<ModifierKey> {
        didSet { saveModifierKeys() }
    }

    @Published var overlayOpacity: Double {
        didSet { saveOverlayOpacity() }
    }

    @Published var showZoneNumbers: Bool {
        didSet { saveShowZoneNumbers() }
    }

    @Published var animationSpeed: AnimationSpeed {
        didSet { saveAnimationSpeed() }
    }

    @Published var windowPicker: WindowPicker {
        didSet { saveWindowPicker() }
    }

    @Published var defaultGridColumns: Int {
        didSet { saveDefaultGridColumns() }
    }

    @Published var defaultGridRows: Int {
        didSet { saveDefaultGridRows() }
    }

    @Published var defaultGridSpacing: Int {
        didSet { saveDefaultGridSpacing() }
    }

    @Published var iCloudSyncEnabled: Bool {
        didSet { saveICloudSyncEnabled() }
    }

    // MARK: - Keys

    private enum Keys {
        static let modifierKeys = "modifierKeys"
        static let overlayOpacity = "overlayOpacity"
        static let showZoneNumbers = "showZoneNumbers"
        static let animationSpeed = "animationSpeed"
        static let windowPicker = "windowPicker"
        static let defaultGridColumns = "defaultGridColumns"
        static let defaultGridRows = "defaultGridRows"
        static let defaultGridSpacing = "defaultGridSpacing"
        static let iCloudSyncEnabled = "iCloudSyncEnabled"
    }

    // MARK: - Initialization

    private init() {
        // Load values or use defaults
        if let keysData = defaults.data(forKey: Keys.modifierKeys),
           let keysArray = try? JSONDecoder().decode([String].self, from: keysData) {
            self.modifierKeys = Set(keysArray.compactMap { ModifierKey(rawValue: $0) })
        } else {
            self.modifierKeys = [.command, .option, .control] // Default: Cmd+Opt+Ctrl
        }
        self.overlayOpacity = defaults.object(forKey: Keys.overlayOpacity) as? Double ?? 0.3
        self.showZoneNumbers = defaults.object(forKey: Keys.showZoneNumbers) as? Bool ?? true
        self.animationSpeed = AnimationSpeed(rawValue: defaults.string(forKey: Keys.animationSpeed) ?? "") ?? .normal
        self.windowPicker = WindowPicker(rawValue: defaults.string(forKey: Keys.windowPicker) ?? "") ?? .frontMost
        self.defaultGridColumns = defaults.object(forKey: Keys.defaultGridColumns) as? Int ?? 12
        self.defaultGridRows = defaults.object(forKey: Keys.defaultGridRows) as? Int ?? 8
        self.defaultGridSpacing = defaults.object(forKey: Keys.defaultGridSpacing) as? Int ?? 8
        self.iCloudSyncEnabled = defaults.object(forKey: Keys.iCloudSyncEnabled) as? Bool ?? false

        // Set up iCloud sync observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iCloudStoreDidChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: ubiquitousStore
        )

        // Sync from iCloud if enabled
        if iCloudSyncEnabled {
            syncFromICloud()
        }
    }

    // MARK: - Save Methods

    private func saveModifierKeys() {
        let keysArray = Array(modifierKeys.map { $0.rawValue })
        if let keysData = try? JSONEncoder().encode(keysArray) {
            defaults.set(keysData, forKey: Keys.modifierKeys)
            if let keysString = String(data: keysData, encoding: .utf8) {
                syncToICloudIfEnabled(key: Keys.modifierKeys, value: keysString)
            }
        }
        applyModifierKeysChange()
    }

    private func saveOverlayOpacity() {
        defaults.set(overlayOpacity, forKey: Keys.overlayOpacity)
        syncToICloudIfEnabled(key: Keys.overlayOpacity, value: overlayOpacity)
        applyOverlayOpacityChange()
    }

    private func saveShowZoneNumbers() {
        defaults.set(showZoneNumbers, forKey: Keys.showZoneNumbers)
        syncToICloudIfEnabled(key: Keys.showZoneNumbers, value: showZoneNumbers)
        applyShowZoneNumbersChange()
    }

    private func saveAnimationSpeed() {
        defaults.set(animationSpeed.rawValue, forKey: Keys.animationSpeed)
        syncToICloudIfEnabled(key: Keys.animationSpeed, value: animationSpeed.rawValue)
        applyAnimationSpeedChange()
    }

    private func saveWindowPicker() {
        defaults.set(windowPicker.rawValue, forKey: Keys.windowPicker)
        syncToICloudIfEnabled(key: Keys.windowPicker, value: windowPicker.rawValue)
    }

    private func saveDefaultGridColumns() {
        defaults.set(defaultGridColumns, forKey: Keys.defaultGridColumns)
        syncToICloudIfEnabled(key: Keys.defaultGridColumns, value: defaultGridColumns)
    }

    private func saveDefaultGridRows() {
        defaults.set(defaultGridRows, forKey: Keys.defaultGridRows)
        syncToICloudIfEnabled(key: Keys.defaultGridRows, value: defaultGridRows)
    }

    private func saveDefaultGridSpacing() {
        defaults.set(defaultGridSpacing, forKey: Keys.defaultGridSpacing)
        syncToICloudIfEnabled(key: Keys.defaultGridSpacing, value: defaultGridSpacing)
    }

    private func saveICloudSyncEnabled() {
        defaults.set(iCloudSyncEnabled, forKey: Keys.iCloudSyncEnabled)

        if iCloudSyncEnabled {
            syncAllToICloud()
        }
    }

    // MARK: - Apply Changes

    private func applyModifierKeysChange() {
        // Update WindowSnapController with new modifier keys
        let flags = modifierKeys.reduce(CGEventFlags()) { result, key in
            result.union(key.cgEventFlags)
        }
        WindowSnapController.shared.setRequiredModifier(flags)
    }

    private func applyOverlayOpacityChange() {
        // Update overlay manager
        ZoneOverlayManager.shared.updateConfiguration(opacity: overlayOpacity)
    }

    private func applyShowZoneNumbersChange() {
        // Update overlay manager
        ZoneOverlayManager.shared.updateConfiguration(showNumbers: showZoneNumbers)
    }

    private func applyAnimationSpeedChange() {
        // Update WindowSnapper animation settings
        let (enabled, duration) = animationSpeed.configuration
        WindowSnapper.shared.configureAnimation(enabled: enabled, duration: duration)
    }

    // MARK: - iCloud Sync

    private func syncToICloudIfEnabled(key: String, value: Any) {
        guard iCloudSyncEnabled else { return }

        if let stringValue = value as? String {
            ubiquitousStore.set(stringValue, forKey: key)
        } else if let doubleValue = value as? Double {
            ubiquitousStore.set(doubleValue, forKey: key)
        } else if let intValue = value as? Int {
            ubiquitousStore.set(Int64(intValue), forKey: key)
        } else if let boolValue = value as? Bool {
            ubiquitousStore.set(boolValue, forKey: key)
        }

        ubiquitousStore.synchronize()
    }

    private func syncAllToICloud() {
        if let keysData = try? JSONEncoder().encode(Array(modifierKeys.map { $0.rawValue })),
           let keysString = String(data: keysData, encoding: .utf8) {
            syncToICloudIfEnabled(key: Keys.modifierKeys, value: keysString)
        }
        syncToICloudIfEnabled(key: Keys.overlayOpacity, value: overlayOpacity)
        syncToICloudIfEnabled(key: Keys.showZoneNumbers, value: showZoneNumbers)
        syncToICloudIfEnabled(key: Keys.animationSpeed, value: animationSpeed.rawValue)
        syncToICloudIfEnabled(key: Keys.windowPicker, value: windowPicker.rawValue)
        syncToICloudIfEnabled(key: Keys.defaultGridColumns, value: defaultGridColumns)
        syncToICloudIfEnabled(key: Keys.defaultGridRows, value: defaultGridRows)
        syncToICloudIfEnabled(key: Keys.defaultGridSpacing, value: defaultGridSpacing)
    }

    private func syncFromICloud() {
        if let value = ubiquitousStore.string(forKey: Keys.modifierKeys),
           let keysData = value.data(using: .utf8),
           let keysArray = try? JSONDecoder().decode([String].self, from: keysData) {
            modifierKeys = Set(keysArray.compactMap { ModifierKey(rawValue: $0) })
        }
        if let value = ubiquitousStore.object(forKey: Keys.overlayOpacity) as? Double {
            overlayOpacity = value
        }
        if let value = ubiquitousStore.object(forKey: Keys.showZoneNumbers) as? Bool {
            showZoneNumbers = value
        }
        if let value = ubiquitousStore.string(forKey: Keys.animationSpeed) {
            animationSpeed = AnimationSpeed(rawValue: value) ?? .normal
        }
        if let value = ubiquitousStore.string(forKey: Keys.windowPicker) {
            windowPicker = WindowPicker(rawValue: value) ?? .frontMost
        }
        if let value = ubiquitousStore.object(forKey: Keys.defaultGridColumns) as? Int {
            defaultGridColumns = value
        }
        if let value = ubiquitousStore.object(forKey: Keys.defaultGridRows) as? Int {
            defaultGridRows = value
        }
        if let value = ubiquitousStore.object(forKey: Keys.defaultGridSpacing) as? Int {
            defaultGridSpacing = value
        }
    }

    @objc private func iCloudStoreDidChange(_ notification: Notification) {
        guard iCloudSyncEnabled else { return }
        syncFromICloud()
    }

    // MARK: - Public Methods

    /// Resets all preferences to default values
    func resetToDefaults() {
        modifierKeys = [.command, .option, .control]
        overlayOpacity = 0.3
        showZoneNumbers = true
        animationSpeed = .normal
        windowPicker = .frontMost
        defaultGridColumns = 12
        defaultGridRows = 8
        defaultGridSpacing = 8

        print("✓ Preferences reset to defaults")
    }

    /// Returns default grid settings
    var defaultGridSettings: GridSettings {
        return GridSettings(columns: defaultGridColumns, rows: defaultGridRows, spacing: defaultGridSpacing)
    }
}

// MARK: - Enums

enum ModifierKey: String, CaseIterable {
    case command = "command"
    case option = "option"
    case control = "control"
    case shift = "shift"

    var cgEventFlags: CGEventFlags {
        switch self {
        case .command: return .maskCommand
        case .option: return .maskAlternate
        case .control: return .maskControl
        case .shift: return .maskShift
        }
    }
}

enum AnimationSpeed: String, CaseIterable {
    case off = "off"
    case slow = "slow"
    case normal = "normal"
    case fast = "fast"

    var configuration: (enabled: Bool, duration: TimeInterval) {
        switch self {
        case .off: return (false, 0)
        case .slow: return (true, 0.5)
        case .normal: return (true, 0.25)
        case .fast: return (true, 0.1)
        }
    }
}

enum WindowPicker: String, CaseIterable {
    case frontMost = "frontMost"
    case underCursor = "underCursor"
}
