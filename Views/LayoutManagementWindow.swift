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
    @Environment(\.presentationMode) private var presentationMode
    @State private var editingLayoutName: String = ""

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
                            TextField("Name", text: $editingLayoutName, onCommit: {
                                if !editingLayoutName.isEmpty {
                                    viewModel.updateLayoutName(editingLayoutName)
                                }
                            })
                            .textFieldStyle(.roundedBorder)
                            .onAppear {
                                editingLayoutName = layout.layoutName
                            }
                            .onChange(of: viewModel.selectedLayoutID) { _ in
                                if let newLayout = viewModel.selectedLayout {
                                    editingLayoutName = newLayout.layoutName
                                }
                            }
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

                            ForEach(layout.monitorConfiguration.displays, id: \.displayID) { display in
                                let displayZones = layout.zones.filter { $0.displayID == display.displayID }
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(display.name)
                                            .font(.body)
                                        Text("\(displayZones.count) zone(s)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if display.isPrimary {
                                        Text("Primary")
                                            .font(.caption)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.2))
                                            .cornerRadius(4)
                                    }
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(6)
                            }

                            Text("Total: \(layout.zones.count) zone(s)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
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
                                Stepper("\(layout.gridSettings.columns)",
                                       value: Binding(
                                           get: { layout.gridSettings.columns },
                                           set: { viewModel.updateGridColumns($0) }
                                       ),
                                       in: 1...24)
                            }
                            HStack {
                                Text("Rows:")
                                Spacer()
                                Stepper("\(layout.gridSettings.rows)",
                                       value: Binding(
                                           get: { layout.gridSettings.rows },
                                           set: { viewModel.updateGridRows($0) }
                                       ),
                                       in: 1...16)
                            }
                            HStack {
                                Text("Spacing:")
                                Spacer()
                                Stepper("\(layout.gridSettings.spacing)px",
                                       value: Binding(
                                           get: { layout.gridSettings.spacing },
                                           set: { viewModel.updateGridSpacing($0) }
                                       ),
                                       in: 0...32)
                            }
                        }

                        Divider()

                        // Zones
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Zones")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button(action: {
                                    viewModel.addZone()
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Zone")
                                }
                                .buttonStyle(BorderedButtonStyle())
                            }

                            ForEach(layout.zones) { zone in
                                HStack(spacing: 8) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Zone \(zone.zoneNumber)")
                                            .font(.body)
                                            .fontWeight(.medium)
                                        if let grid = zone.gridDefinition {
                                            Text("Cols \(grid.startColumn)-\(grid.endColumn), Rows \(grid.startRow)-\(grid.endRow)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Text("Display: \(layout.monitorConfiguration.displays.first(where: { $0.displayID == zone.displayID })?.name ?? "Unknown")")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Button(action: {
                                        viewModel.editZoneGrid(zone)
                                    }) {
                                        Image(systemName: "slider.horizontal.3")
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    .help("Edit zone grid definition")

                                    Button(action: {
                                        viewModel.removeZone(zone)
                                    }) {
                                        Image(systemName: "trash")
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    .foregroundColor(.red)
                                    .help("Remove zone")
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 8)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(6)
                            }
                        }

                        Divider()

                        // Action Buttons
                        VStack(spacing: 8) {
                            Button("Apply Layout") {
                                viewModel.applyLayout()
                            }
                            .buttonStyle(DefaultButtonStyle())
                            .frame(maxWidth: .infinity)

                            if layout.layoutType == .zonesAndApps {
                                Button("Restore Apps") {
                                    viewModel.restoreApps()
                                }
                                .buttonStyle(BorderedButtonStyle())
                                .frame(maxWidth: .infinity)
                            }

                            Button("Edit Zones") {
                                viewModel.editZones()
                            }
                            .buttonStyle(BorderedButtonStyle())
                            .frame(maxWidth: .infinity)

                            Divider()

                            Button("Duplicate") {
                                viewModel.duplicateLayout()
                            }
                            .buttonStyle(BorderedButtonStyle())
                            .frame(maxWidth: .infinity)

                            Button("Delete") {
                                viewModel.deleteLayout()
                            }
                            .buttonStyle(BorderedButtonStyle())
                            .foregroundColor(.red)
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

        // Detect current monitor configuration
        let monitorConfig = MonitorConfiguration.detectCurrentConfiguration()
        let gridSettings = PreferencesManager.shared.defaultGridSettings

        // Create default zones for all displays
        let defaultZones = createDefaultZones(for: monitorConfig, gridSettings: gridSettings)

        let newLayout = Layout(
            layoutName: "Layout \(layouts.count + 1)",
            layoutType: .zonesOnly,
            monitorConfiguration: monitorConfig,
            zones: defaultZones,
            gridSettings: gridSettings
        )

        do {
            try fileManager.saveLayout(newLayout)
            loadLayouts()
            selectedLayoutID = newLayout.id
        } catch {
            showAlert(title: "Error", message: "Failed to create layout: \(error.localizedDescription)")
        }
    }

    private func createDefaultZones(for monitorConfig: MonitorConfiguration, gridSettings: GridSettings) -> [Zone] {
        var zones: [Zone] = []
        var zoneNumber = 1

        // Create 2 zones (left/right split) for each display
        for display in monitorConfig.displays {
            let leftGrid = GridDefinition.leftHalf(columns: gridSettings.columns, rows: gridSettings.rows)
            let rightGrid = GridDefinition.rightHalf(columns: gridSettings.columns, rows: gridSettings.rows)

            let leftZone = Zone(
                zoneNumber: zoneNumber,
                displayID: display.displayID,
                bounds: CGRect(x: 0, y: 0, width: 100, height: 100), // Will be calculated from grid
                gridDefinition: leftGrid
            )
            zoneNumber += 1

            let rightZone = Zone(
                zoneNumber: zoneNumber,
                displayID: display.displayID,
                bounds: CGRect(x: 0, y: 0, width: 100, height: 100), // Will be calculated from grid
                gridDefinition: rightGrid
            )
            zoneNumber += 1

            zones.append(leftZone)
            zones.append(rightZone)
        }

        return zones
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

    func updateGridColumns(_ columns: Int) {
        guard var layout = selectedLayout else { return }
        layout.gridSettings.columns = columns
        saveLayout(layout)
    }

    func updateGridRows(_ rows: Int) {
        guard var layout = selectedLayout else { return }
        layout.gridSettings.rows = rows
        saveLayout(layout)
    }

    func updateGridSpacing(_ spacing: Int) {
        guard var layout = selectedLayout else { return }
        layout.gridSettings.spacing = spacing
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
        AppRestoration.shared.restoreApps(from: layout)
    }

    func addZone() {
        guard var layout = selectedLayout else { return }

        // Get the first display (or primary display)
        guard let display = layout.monitorConfiguration.displays.first else {
            showAlert(title: "Error", message: "No displays available")
            return
        }

        // Create a new zone number
        let maxZoneNumber = layout.zones.map { $0.zoneNumber }.max() ?? 0
        let newZoneNumber = maxZoneNumber + 1

        // Create a default grid definition (quarter of the screen in top-left)
        let columns = layout.gridSettings.columns
        let rows = layout.gridSettings.rows
        let gridDef = GridDefinition(
            startColumn: 1,
            endColumn: columns / 2,
            startRow: 1,
            endRow: rows / 2
        )

        let newZone = Zone(
            zoneNumber: newZoneNumber,
            displayID: display.displayID,
            bounds: CGRect(x: 0, y: 0, width: 100, height: 100), // Will be calculated from grid
            gridDefinition: gridDef
        )

        layout.zones.append(newZone)
        saveLayout(layout)
    }

    func removeZone(_ zone: Zone) {
        guard var layout = selectedLayout else { return }

        // Confirm deletion
        let alert = NSAlert()
        alert.messageText = "Remove Zone \(zone.zoneNumber)?"
        alert.informativeText = "This cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Remove")
        alert.addButton(withTitle: "Cancel")

        if alert.runModal() == .alertFirstButtonReturn {
            layout.zones.removeAll { $0.id == zone.id }
            saveLayout(layout)
        }
    }

    func editZoneGrid(_ zone: Zone) {
        guard var layout = selectedLayout else { return }
        guard let zoneIndex = layout.zones.firstIndex(where: { $0.id == zone.id }) else { return }

        // Show a dialog to edit the grid definition
        let alert = NSAlert()
        alert.messageText = "Edit Zone \(zone.zoneNumber) Grid"
        alert.informativeText = "Define the zone in terms of grid cells (1-based indices)"
        alert.alertStyle = .informational

        // Create text fields for grid definition
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 120))

        let startColLabel = NSTextField(labelWithString: "Start Column:")
        startColLabel.frame = NSRect(x: 0, y: 90, width: 100, height: 20)
        view.addSubview(startColLabel)

        let startColField = NSTextField(frame: NSRect(x: 110, y: 90, width: 50, height: 22))
        startColField.integerValue = zone.gridDefinition?.startColumn ?? 1
        view.addSubview(startColField)

        let endColLabel = NSTextField(labelWithString: "End Column:")
        endColLabel.frame = NSRect(x: 0, y: 60, width: 100, height: 20)
        view.addSubview(endColLabel)

        let endColField = NSTextField(frame: NSRect(x: 110, y: 60, width: 50, height: 22))
        endColField.integerValue = zone.gridDefinition?.endColumn ?? layout.gridSettings.columns
        view.addSubview(endColField)

        let startRowLabel = NSTextField(labelWithString: "Start Row:")
        startRowLabel.frame = NSRect(x: 0, y: 30, width: 100, height: 20)
        view.addSubview(startRowLabel)

        let startRowField = NSTextField(frame: NSRect(x: 110, y: 30, width: 50, height: 22))
        startRowField.integerValue = zone.gridDefinition?.startRow ?? 1
        view.addSubview(startRowField)

        let endRowLabel = NSTextField(labelWithString: "End Row:")
        endRowLabel.frame = NSRect(x: 0, y: 0, width: 100, height: 20)
        view.addSubview(endRowLabel)

        let endRowField = NSTextField(frame: NSRect(x: 110, y: 0, width: 50, height: 22))
        endRowField.integerValue = zone.gridDefinition?.endRow ?? layout.gridSettings.rows
        view.addSubview(endRowField)

        alert.accessoryView = view
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")

        if alert.runModal() == .alertFirstButtonReturn {
            let startCol = max(1, min(layout.gridSettings.columns, startColField.integerValue))
            let endCol = max(startCol, min(layout.gridSettings.columns, endColField.integerValue))
            let startRow = max(1, min(layout.gridSettings.rows, startRowField.integerValue))
            let endRow = max(startRow, min(layout.gridSettings.rows, endRowField.integerValue))

            let gridDef = GridDefinition(
                startColumn: startCol,
                endColumn: endCol,
                startRow: startRow,
                endRow: endRow
            )

            layout.zones[zoneIndex].gridDefinition = gridDef
            saveLayout(layout)
        }
    }

    func editZones() {
        guard let layout = selectedLayout else { return }

        // For now, just show a simple info dialog
        // TODO: Implement full interactive zone editor
        showNotification(
            title: "Zone Editor",
            message: "Interactive zone editing will be available in a future update. For now, you can adjust grid settings to change zone layout."
        )
    }

    func updateZones(_ zones: [Zone]) {
        guard var layout = selectedLayout else { return }

        // Replace zones for the edited display
        for zone in zones {
            if let index = layout.zones.firstIndex(where: { $0.id == zone.id }) {
                layout.zones[index] = zone
            } else {
                layout.zones.append(zone)
            }
        }

        saveLayout(layout)
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
