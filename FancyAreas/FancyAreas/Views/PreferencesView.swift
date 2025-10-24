//
//  PreferencesView.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import SwiftUI

/// Main preferences window with tabbed interface
struct PreferencesView: View {
    @StateObject private var preferencesManager = PreferencesManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TabView {
            GeneralPreferencesView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
                .tag(0)

            // Future tabs can be added here
            // AdvancedPreferencesView()
            //     .tabItem {
            //         Label("Advanced", systemImage: "slider.horizontal.3")
            //     }
            //     .tag(1)
        }
        .frame(width: 600, height: 500)
    }
}

/// General preferences tab
struct GeneralPreferencesView: View {
    @StateObject private var preferencesManager = PreferencesManager.shared
    @StateObject private var launchOnLoginManager = LaunchOnLoginManager.shared

    var body: some View {
        Form {
            // Launch Settings
            Section("Launch Settings") {
                Toggle("Launch on login", isOn: Binding(
                    get: { launchOnLoginManager.isEnabled },
                    set: { launchOnLoginManager.isEnabled = $0 }
                ))
                .help("Automatically start FancyAreas when you log in")
            }

            // Zone Snapping Behavior
            Section("Zone Snapping Behavior") {
                Picker("Modifier key:", selection: $preferencesManager.modifierKey) {
                    Text("Command (⌘)").tag(ModifierKey.command)
                    Text("Option (⌥)").tag(ModifierKey.option)
                    Text("Control (⌃)").tag(ModifierKey.control)
                    Text("Shift (⇧)").tag(ModifierKey.shift)
                }
                .help("Hold this key while dragging to show zones")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Overlay opacity: \(Int(preferencesManager.overlayOpacity * 100))%")
                    Slider(value: $preferencesManager.overlayOpacity, in: 0.1...1.0)
                }
                .help("Transparency of zone overlay")

                Toggle("Show zone numbers", isOn: $preferencesManager.showZoneNumbers)
                    .help("Display zone numbers in overlay")

                Picker("Animation speed:", selection: $preferencesManager.animationSpeed) {
                    Text("Off").tag(AnimationSpeed.off)
                    Text("Slow").tag(AnimationSpeed.slow)
                    Text("Normal").tag(AnimationSpeed.normal)
                    Text("Fast").tag(AnimationSpeed.fast)
                }
                .help("Window snap animation speed")
            }

            // Window Behavior
            Section("Window Behavior") {
                Picker("Window to snap:", selection: $preferencesManager.windowPicker) {
                    Text("Front most window").tag(WindowPicker.frontMost)
                    Text("Window under cursor").tag(WindowPicker.underCursor)
                }
                .help("Which window to snap when multiple are available")
            }

            // Grid Settings
            Section("Default Grid Settings") {
                HStack {
                    Text("Columns:")
                    Stepper("\(preferencesManager.defaultGridColumns)",
                           value: $preferencesManager.defaultGridColumns,
                           in: 1...12)
                }

                HStack {
                    Text("Rows:")
                    Stepper("\(preferencesManager.defaultGridRows)",
                           value: $preferencesManager.defaultGridRows,
                           in: 1...8)
                }

                HStack {
                    Text("Spacing:")
                    Stepper("\(preferencesManager.defaultGridSpacing)px",
                           value: $preferencesManager.defaultGridSpacing,
                           in: 0...20)
                }
            }

            // iCloud Integration
            Section("iCloud") {
                Toggle("Sync preferences with iCloud", isOn: $preferencesManager.iCloudSyncEnabled)
                    .help("Sync settings across all your Macs")

                if preferencesManager.iCloudSyncEnabled {
                    Text("iCloud sync is enabled")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // System Actions
            Section {
                HStack {
                    Spacer()
                    Button("Reset to Defaults", role: .destructive) {
                        showResetConfirmation()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private func showResetConfirmation() {
        let alert = NSAlert()
        alert.messageText = "Reset All Preferences?"
        alert.informativeText = "This will reset all settings to their default values. This cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Reset")
        alert.addButton(withTitle: "Cancel")

        if alert.runModal() == .alertFirstButtonReturn {
            preferencesManager.resetToDefaults()
        }
    }
}

// MARK: - Preview

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
