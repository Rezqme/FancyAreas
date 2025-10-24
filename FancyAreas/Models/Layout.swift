//
//  Layout.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import Foundation

/// Represents a complete zone layout configuration
/// This is the root model for .fancyareas files
struct Layout: Codable, Identifiable {
    var id: UUID
    var layoutName: String
    var layoutType: LayoutType
    var created: Date
    var modified: Date
    var tags: [String]
    var monitorConfiguration: MonitorConfiguration
    var zones: [Zone]
    var gridSettings: GridSettings

    enum LayoutType: String, Codable {
        case zonesOnly = "zones_only"
        case zonesAndApps = "zones_and_apps"
    }

    init(
        id: UUID = UUID(),
        layoutName: String,
        layoutType: LayoutType,
        created: Date = Date(),
        modified: Date = Date(),
        tags: [String] = [],
        monitorConfiguration: MonitorConfiguration,
        zones: [Zone],
        gridSettings: GridSettings = GridSettings()
    ) {
        self.id = id
        self.layoutName = layoutName
        self.layoutType = layoutType
        self.created = created
        self.modified = modified
        self.tags = tags
        self.monitorConfiguration = monitorConfiguration
        self.zones = zones
        self.gridSettings = gridSettings
    }
}
