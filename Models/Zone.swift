//
//  Zone.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import Foundation
import CoreGraphics

/// Represents a single zone within a layout
/// Zones define the snapping areas for windows
struct Zone: Codable, Identifiable {
    var id: UUID
    var zoneNumber: Int
    var displayID: String
    var bounds: CGRect
    var assignedApp: AssignedApp?

    // Grid-based definition (optional, for grid-based layouts)
    var gridDefinition: GridDefinition?

    init(
        id: UUID = UUID(),
        zoneNumber: Int,
        displayID: String,
        bounds: CGRect,
        assignedApp: AssignedApp? = nil,
        gridDefinition: GridDefinition? = nil
    ) {
        self.id = id
        self.zoneNumber = zoneNumber
        self.displayID = displayID
        self.bounds = bounds
        self.assignedApp = assignedApp
        self.gridDefinition = gridDefinition
    }

    /// Calculates bounds from grid definition
    /// - Parameters:
    ///   - gridSettings: The grid settings (columns, rows, spacing)
    ///   - displayFrame: The display's frame
    /// - Returns: Calculated bounds
    func boundsFromGrid(gridSettings: GridSettings, displayFrame: CGRect) -> CGRect {
        guard let grid = gridDefinition else { return bounds }

        let cellWidth = displayFrame.width / CGFloat(gridSettings.columns)
        let cellHeight = displayFrame.height / CGFloat(gridSettings.rows)
        let spacing = CGFloat(gridSettings.spacing)

        let x = displayFrame.origin.x + cellWidth * CGFloat(grid.startColumn - 1) + spacing / 2
        let y = displayFrame.origin.y + cellHeight * CGFloat(grid.startRow - 1) + spacing / 2
        let width = cellWidth * CGFloat(grid.endColumn - grid.startColumn + 1) - spacing
        let height = cellHeight * CGFloat(grid.endRow - grid.startRow + 1) - spacing

        return CGRect(x: x, y: y, width: width, height: height)
    }
}

/// Defines a zone in terms of grid cells
struct GridDefinition: Codable, Equatable {
    var startColumn: Int  // 1-based
    var endColumn: Int    // 1-based, inclusive
    var startRow: Int     // 1-based
    var endRow: Int       // 1-based, inclusive

    init(startColumn: Int, endColumn: Int, startRow: Int, endRow: Int) {
        self.startColumn = startColumn
        self.endColumn = endColumn
        self.startRow = startRow
        self.endRow = endRow
    }

    /// Creates a grid definition spanning the full grid
    static func fullGrid(columns: Int, rows: Int) -> GridDefinition {
        GridDefinition(startColumn: 1, endColumn: columns, startRow: 1, endRow: rows)
    }

    /// Creates a grid definition for the left half
    static func leftHalf(columns: Int, rows: Int) -> GridDefinition {
        GridDefinition(startColumn: 1, endColumn: columns / 2, startRow: 1, endRow: rows)
    }

    /// Creates a grid definition for the right half
    static func rightHalf(columns: Int, rows: Int) -> GridDefinition {
        GridDefinition(startColumn: (columns / 2) + 1, endColumn: columns, startRow: 1, endRow: rows)
    }
}

// MARK: - CGRect Codable Extension
extension CGRect: Codable {
    enum CodingKeys: String, CodingKey {
        case x, y, width, height
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(CGFloat.self, forKey: .x)
        let y = try container.decode(CGFloat.self, forKey: .y)
        let width = try container.decode(CGFloat.self, forKey: .width)
        let height = try container.decode(CGFloat.self, forKey: .height)
        self.init(x: x, y: y, width: width, height: height)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(origin.x, forKey: .x)
        try container.encode(origin.y, forKey: .y)
        try container.encode(size.width, forKey: .width)
        try container.encode(size.height, forKey: .height)
    }
}

// MARK: - CGSize Codable Extension
extension CGSize: Codable {
    enum CodingKeys: String, CodingKey {
        case width, height
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let width = try container.decode(CGFloat.self, forKey: .width)
        let height = try container.decode(CGFloat.self, forKey: .height)
        self.init(width: width, height: height)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
    }
}

// MARK: - CGPoint Codable Extension
extension CGPoint: Codable {
    enum CodingKeys: String, CodingKey {
        case x, y
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(CGFloat.self, forKey: .x)
        let y = try container.decode(CGFloat.self, forKey: .y)
        self.init(x: x, y: y)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
    }
}
