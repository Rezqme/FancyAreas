//
//  GridSettings.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import Foundation

/// Configuration for grid-based zone creation
/// Defines the grid parameters used in the zone editor
struct GridSettings: Codable, Equatable {
    var columns: Int
    var rows: Int
    var spacing: Int

    init(
        columns: Int = 12,
        rows: Int = 8,
        spacing: Int = 8
    ) {
        self.columns = max(1, min(12, columns))
        self.rows = max(1, min(8, rows))
        self.spacing = max(0, min(20, spacing))
    }

    /// Validates and clamps grid settings to allowed ranges
    mutating func validate() {
        columns = max(1, min(12, columns))
        rows = max(1, min(8, rows))
        spacing = max(0, min(20, spacing))
    }

    /// Returns default grid settings
    static var `default`: GridSettings {
        GridSettings(columns: 12, rows: 8, spacing: 8)
    }
}
