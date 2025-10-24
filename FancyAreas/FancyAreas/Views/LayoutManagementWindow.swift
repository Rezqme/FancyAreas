//
//  LayoutManagementWindow.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import SwiftUI

/// Main layout management window with three-panel design
struct LayoutManagementWindow: View {
    @StateObject private var viewModel = LayoutManagementViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HSplitView {
            // LEFT: Layout List
            layoutListPanel
                .frame(minWidth: 200, maxWidth: 300)

            // CENTER: Zone Preview
            zonePreviewPanel
                .frame(minWidth: 400)

            // RIGHT: Properties Panel
            propertiesPanel
                .frame(minWidth: 250, maxWidth: 350)
        }
        .frame(minWidth: 900, minHeight: 600)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: { viewModel.createNewLayout() }) {
                    Label("New Layout", systemImage: "plus")
                }
                .disabled(viewModel.layouts.count >= 10)
            }
        }
    }

    // MARK: - Layout List Panel

    private var layoutListPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Layouts")
                .font(.headline)
                .padding()

            List(selection: $viewModel.selectedLayoutID) {
                ForEach(viewModel.layouts) { layout in
                    LayoutRowView(layout: layout)
                        .tag(layout.id)
                }

                // Empty slots
                ForEach(viewModel.layouts.count..<10, id: \.self) { index in
                    EmptySlotView(slotNumber: index + 1)
                }
            }

            Divider()

            // New Layout Button
            Button(action: { viewModel.createNewLayout() }) {
                Label("New Layout", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.layouts.count >= 10)
            .padding()
        }
    }

    // MARK: - Zone Preview Panel

    private var zonePreviewPanel: some View {
        VStack {
            if let layout = viewModel.selectedLayout {
                ZonePreviewView(layout: layout)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "square.dashed")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No layout selected")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // MARK: - Properties Panel

    private var propertiesPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let layout = viewModel.selectedLayout {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Layout Name
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Layout Name")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Name", text: Binding(
                                get: { layout.layoutName },
                                set: { viewModel.updateLayoutName($0) }
                            ))
                            .textFieldStyle(.roundedBorder)
                        }

                        Divider()

                        // Layout Type
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Type")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Picker("", selection: Binding(
                                get: { layout.layoutType },
                                set: { viewModel.updateLayoutType($0) }
                            )) {
                                Text("Zones Only").tag(Layout.LayoutType.zonesOnly)
                                Text("Zones + Apps").tag(Layout.LayoutType.zonesAndApps)
                            }
                            .pickerStyle(.segmented)
                        }

                        Divider()

                        // Monitor Configuration
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Monitors")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(layout.monitorConfiguration.displayCount) display(s)")
                                .font(.body)
                        }

                        // Zone Count
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Zones")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(layout.zones.count) zone(s)")
                                .font(.body)
                        }

                        Divider()

                        // Grid Settings
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Grid Settings")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack {
                                Text("Columns:")
                                Spacer()
                                Text("\(layout.gridSettings.columns)")
                            }
                            HStack {
                                Text("Rows:")
                                Spacer()
                                Text("\(layout.gridSettings.rows)")
                            }
                            HStack {
                                Text("Spacing:")
                                Spacer()
                                Text("\(layout.gridSettings.spacing)px")
                            }
                        }

                        Divider()

                        // Action Buttons
                        VStack(spacing: 8) {
                            Button("Apply Layout") {
                                viewModel.applyLayout()
                            }
                            .buttonStyle(.borderedProminent)
                            .frame(maxWidth: .infinity)

                            if layout.layoutType == .zonesAndApps {
                                Button("Restore Apps") {
                                    viewModel.restoreApps()
                                }
                                .buttonStyle(.bordered)
                                .frame(maxWidth: .infinity)
                            }

                            Button("Edit Zones") {
                                viewModel.editZones()
                            }
                            .buttonStyle(.bordered)
                            .frame(maxWidth: .infinity)

                            Divider()

                            Button("Duplicate") {
                                viewModel.duplicateLayout()
                            }
                            .buttonStyle(.bordered)
                            .frame(maxWidth: .infinity)

                            Button("Delete", role: .destructive) {
                                viewModel.deleteLayout()
                            }
                            .buttonStyle(.bordered)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                }
            } else {
                VStack {
                    Text("Select a layout to view properties")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

// MARK: - Layout Row View

struct LayoutRowView: View {
    let layout: Layout

    var body: some View {
        HStack {
            Image(systemName: layout.layoutType == .zonesOnly ? "square" : "square.fill")
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text(layout.layoutName)
                    .font(.body)

                HStack(spacing: 8) {
                    Text("\(layout.zones.count) zones")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if layout.monitorConfiguration.displayCount > 1 {
                        Text("• \(layout.monitorConfiguration.displayCount) displays")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Empty Slot View

struct EmptySlotView: View {
    let slotNumber: Int

    var body: some View {
        HStack {
            Image(systemName: "circle.dashed")
                .foregroundColor(.secondary)

            Text("Empty Slot \(slotNumber)")
                .font(.body)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Zone Preview View

struct ZonePreviewView: View {
    let layout: Layout

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.1)

                // Draw zones
                ForEach(layout.zones) { zone in
                    ZonePreviewRectangle(
                        zone: zone,
                        containerSize: geometry.size,
                        displaySize: layout.monitorConfiguration.displays.first?.resolution ?? CGSize(width: 1920, height: 1080)
                    )
                }
            }
        }
        .cornerRadius(8)
        .padding()
    }
}

// MARK: - Zone Preview Rectangle

struct ZonePreviewRectangle: View {
    let zone: Zone
    let containerSize: CGSize
    let displaySize: CGSize

    private var scaledBounds: CGRect {
        let scaleX = containerSize.width / displaySize.width
        let scaleY = containerSize.height / displaySize.height
        let scale = min(scaleX, scaleY) * 0.9 // 90% to leave margin

        return CGRect(
            x: zone.bounds.origin.x * scale,
            y: zone.bounds.origin.y * scale,
            width: zone.bounds.size.width * scale,
            height: zone.bounds.size.height * scale
        )
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.blue.opacity(0.2))
                .overlay(
                    Rectangle()
                        .strokeBorder(Color.blue, lineWidth: 2)
                )

            Text("\(zone.zoneNumber)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue.opacity(0.6))
        }
        .frame(width: scaledBounds.width, height: scaledBounds.height)
        .position(
            x: scaledBounds.origin.x + scaledBounds.width / 2,
            y: scaledBounds.origin.y + scaledBounds.height / 2
        )
    }
}

// MARK: - View Model

class LayoutManagementViewModel: ObservableObject {
    @Published var layouts: [Layout] = []
    @Published var selectedLayoutID: UUID?

    private let fileManager = LayoutFileManager.shared

    var selectedLayout: Layout? {
        layouts.first { $0.id == selectedLayoutID }
    }

    init() {
        loadLayouts()
    }

    func loadLayouts() {
        do {
            layouts = try fileManager.listLayouts()
        } catch {
            print("Error loading layouts: \(error)")
            layouts = []
        }
    }

    func createNewLayout() {
        guard layouts.count < 10 else {
            showAlert(title: "Layout Limit Reached", message: "You can only have up to 10 layouts.")
            return
        }

        // Create new layout with default settings
        let display = Display(
            displayID: "primary",
            name: "Primary Display",
            resolution: CGSize(width: 1920, height: 1080),
            position: CGPoint(x: 0, y: 0),
            isPrimary: true
        )

        let defaultZones = createDefaultZones()

        let newLayout = Layout(
            layoutName: "Layout \(layouts.count + 1)",
            layoutType: .zonesOnly,
            monitorConfiguration: MonitorConfiguration(displays: [display]),
            zones: defaultZones,
            gridSettings: PreferencesManager.shared.defaultGridSettings
        )

        do {
            try fileManager.saveLayout(newLayout)
            loadLayouts()
            selectedLayoutID = newLayout.id
        } catch {
            showAlert(title: "Error", message: "Failed to create layout: \(error.localizedDescription)")
        }
    }

    private func createDefaultZones() -> [Zone] {
        // Create 2-column layout by default
        return [
            Zone(zoneNumber: 1, displayID: "primary", bounds: CGRect(x: 0, y: 0, width: 960, height: 1080)),
            Zone(zoneNumber: 2, displayID: "primary", bounds: CGRect(x: 960, y: 0, width: 960, height: 1080))
        ]
    }

    func updateLayoutName(_ name: String) {
        guard var layout = selectedLayout else { return }
        layout.layoutName = name
        saveLayout(layout)
    }

    func updateLayoutType(_ type: Layout.LayoutType) {
        guard var layout = selectedLayout else { return }
        layout.layoutType = type
        saveLayout(layout)
    }

    func duplicateLayout() {
        guard var layout = selectedLayout else { return }
        guard layouts.count < 10 else {
            showAlert(title: "Layout Limit Reached", message: "You can only have up to 10 layouts.")
            return
        }

        layout.id = UUID()
        layout.layoutName = layout.layoutName + " Copy"
        layout.created = Date()
        layout.modified = Date()

        do {
            try fileManager.saveLayout(layout)
            loadLayouts()
            selectedLayoutID = layout.id
        } catch {
            showAlert(title: "Error", message: "Failed to duplicate layout: \(error.localizedDescription)")
        }
    }

    func deleteLayout() {
        guard let layout = selectedLayout else { return }

        let alert = NSAlert()
        alert.messageText = "Delete '\(layout.layoutName)'?"
        alert.informativeText = "This cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")

        if alert.runModal() == .alertFirstButtonReturn {
            do {
                try fileManager.deleteLayout(id: layout.id)
                selectedLayoutID = nil
                loadLayouts()
            } catch {
                showAlert(title: "Error", message: "Failed to delete layout: \(error.localizedDescription)")
            }
        }
    }

    func applyLayout() {
        guard let layout = selectedLayout else { return }
        ZoneManager.shared.activateLayout(layout)
        showNotification(title: "Layout Activated", message: "'\(layout.layoutName)' is now active")
    }

    func restoreApps() {
        guard let layout = selectedLayout else { return }
        // TODO: Implement app restoration (Task 19)
        showNotification(title: "Restore Apps", message: "App restoration coming soon...")
    }

    func editZones() {
        // TODO: Open zone editor (Task 16)
        showNotification(title: "Edit Zones", message: "Zone editor coming soon...")
    }

    private func saveLayout(_ layout: Layout) {
        var updatedLayout = layout
        updatedLayout.modified = Date()

        do {
            try fileManager.saveLayout(updatedLayout)
            loadLayouts()
        } catch {
            showAlert(title: "Error", message: "Failed to save layout: \(error.localizedDescription)")
        }
    }

    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }

    private func showNotification(title: String, message: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = message
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
}

// MARK: - Preview

struct LayoutManagementWindow_Previews: PreviewProvider {
    static var previews: some View {
        LayoutManagementWindow()
    }
}
