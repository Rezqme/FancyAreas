//
//  ZoneManager.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import Foundation
import CoreGraphics

/// Manages the active zone layout and provides zone detection functionality
/// Optimized for fast zone lookups during window dragging
class ZoneManager {

    // MARK: - Properties

    static let shared = ZoneManager()

    private var activeLayout: Layout?
    private var zoneCache: [String: [Zone]] = [:] // Display ID -> Zones
    private var spatialIndex: [String: SpatialGrid] = [:] // Display ID -> Spatial Grid

    /// The currently active layout
    var currentLayout: Layout? {
        return activeLayout
    }

    /// Returns true if a layout is currently active
    var hasActiveLayout: Bool {
        return activeLayout != nil
    }

    // MARK: - Public Methods

    /// Activates a zone layout
    /// - Parameter layout: The layout to activate
    func activateLayout(_ layout: Layout) {
        activeLayout = layout

        // Build zone cache indexed by display ID
        zoneCache.removeAll()
        spatialIndex.removeAll()

        // Calculate actual bounds from grid definitions if available
        var zonesWithCalculatedBounds: [Zone] = []
        for zone in layout.zones {
            var updatedZone = zone

            // If zone has a grid definition, calculate its actual bounds
            if zone.gridDefinition != nil {
                if let display = layout.monitorConfiguration.displays.first(where: { $0.displayID == zone.displayID }) {
                    updatedZone.bounds = zone.boundsFromGrid(gridSettings: layout.gridSettings, displayFrame: display.frame)
                }
            }

            zonesWithCalculatedBounds.append(updatedZone)

            if zoneCache[zone.displayID] == nil {
                zoneCache[zone.displayID] = []
            }
            zoneCache[zone.displayID]?.append(updatedZone)
        }

        // Update active layout with calculated bounds
        var updatedLayout = layout
        updatedLayout.zones = zonesWithCalculatedBounds
        activeLayout = updatedLayout

        // Build spatial index for each display
        for (displayID, zones) in zoneCache {
            spatialIndex[displayID] = SpatialGrid(zones: zones)
        }

        print("✓ Layout activated: \(layout.layoutName) with \(layout.zones.count) zones")
    }

    /// Deactivates the current layout
    func deactivateLayout() {
        activeLayout = nil
        zoneCache.removeAll()
        spatialIndex.removeAll()
        print("✓ Layout deactivated")
    }

    /// Gets all zones for a specific display
    /// - Parameter displayID: The display identifier
    /// - Returns: Array of zones for the display
    func getZones(for displayID: String) -> [Zone] {
        return zoneCache[displayID] ?? []
    }

    /// Detects which zone contains a given point
    /// - Parameters:
    ///   - point: The point to check (in screen coordinates)
    ///   - displayID: The display identifier
    /// - Returns: The zone containing the point, or nil if no zone found
    func detectZone(at point: CGPoint, on displayID: String) -> Zone? {
        // Use spatial index for fast lookup
        if let grid = spatialIndex[displayID] {
            return grid.findZone(at: point)
        }

        // Fallback: linear search
        let zones = getZones(for: displayID)
        return zones.first { zone in
            zone.bounds.contains(point)
        }
    }

    /// Gets the bounds for a specific zone
    /// - Parameters:
    ///   - zoneNumber: The zone number
    ///   - displayID: The display identifier
    /// - Returns: The zone bounds, or nil if not found
    func getZoneBounds(zoneNumber: Int, displayID: String) -> CGRect? {
        let zones = getZones(for: displayID)
        return zones.first { $0.zoneNumber == zoneNumber }?.bounds
    }

    /// Gets all zones across all displays
    /// - Returns: Array of all zones in the active layout
    func getAllZones() -> [Zone] {
        return activeLayout?.zones ?? []
    }

    /// Gets the zone at a specific index
    /// - Parameter index: The zone index
    /// - Returns: The zone, or nil if index is out of bounds
    func getZone(at index: Int) -> Zone? {
        guard let zones = activeLayout?.zones, index >= 0 && index < zones.count else {
            return nil
        }
        return zones[index]
    }

    /// Finds zones near a point (within a threshold distance)
    /// - Parameters:
    ///   - point: The point to search around
    ///   - displayID: The display identifier
    ///   - threshold: Maximum distance from point (in pixels)
    /// - Returns: Array of zones within threshold, sorted by distance
    func findNearbyZones(at point: CGPoint, on displayID: String, threshold: CGFloat = 50) -> [Zone] {
        let zones = getZones(for: displayID)

        return zones
            .map { zone in
                (zone: zone, distance: distance(from: point, to: zone.bounds))
            }
            .filter { $0.distance <= threshold }
            .sorted { $0.distance < $1.distance }
            .map { $0.zone }
    }

    /// Checks if a zone configuration is valid for the current monitor setup
    /// - Parameter layout: The layout to validate
    /// - Returns: True if valid, false otherwise
    func validateLayout(_ layout: Layout) -> Bool {
        // Check that all zones are within their display bounds
        for zone in layout.zones {
            guard let display = layout.monitorConfiguration.displays.first(where: { $0.displayID == zone.displayID }) else {
                return false
            }

            // Check if zone is within display bounds
            if !display.frame.contains(zone.bounds) {
                return false
            }
        }

        return true
    }

    // MARK: - Private Methods

    /// Calculates the minimum distance from a point to a rectangle
    /// - Parameters:
    ///   - point: The point
    ///   - rect: The rectangle
    /// - Returns: The minimum distance
    private func distance(from point: CGPoint, to rect: CGRect) -> CGFloat {
        // If point is inside rectangle, distance is 0
        if rect.contains(point) {
            return 0
        }

        // Calculate distance to nearest edge
        let dx = max(rect.minX - point.x, 0, point.x - rect.maxX)
        let dy = max(rect.minY - point.y, 0, point.y - rect.maxY)

        return sqrt(dx * dx + dy * dy)
    }
}

// MARK: - Spatial Grid

/// A spatial grid for fast zone lookup
/// Divides the display into cells and tracks which zones overlap each cell
private class SpatialGrid {
    private let cellSize: CGFloat = 100 // 100 pixels per cell
    private var grid: [GridCell: [Zone]] = [:]
    private let zones: [Zone]

    struct GridCell: Hashable {
        let x: Int
        let y: Int
    }

    init(zones: [Zone]) {
        self.zones = zones
        buildGrid()
    }

    /// Builds the spatial grid
    private func buildGrid() {
        for zone in zones {
            let cells = getCellsForRect(zone.bounds)
            for cell in cells {
                if grid[cell] == nil {
                    grid[cell] = []
                }
                grid[cell]?.append(zone)
            }
        }
    }

    /// Gets the grid cells that overlap a rectangle
    /// - Parameter rect: The rectangle
    /// - Returns: Array of grid cells
    private func getCellsForRect(_ rect: CGRect) -> [GridCell] {
        let minX = Int(floor(rect.minX / cellSize))
        let maxX = Int(ceil(rect.maxX / cellSize))
        let minY = Int(floor(rect.minY / cellSize))
        let maxY = Int(ceil(rect.maxY / cellSize))

        var cells: [GridCell] = []

        for x in minX...maxX {
            for y in minY...maxY {
                cells.append(GridCell(x: x, y: y))
            }
        }

        return cells
    }

    /// Finds the zone containing a point
    /// - Parameter point: The point to search
    /// - Returns: The zone containing the point, or nil
    func findZone(at point: CGPoint) -> Zone? {
        let cell = GridCell(x: Int(floor(point.x / cellSize)),
                           y: Int(floor(point.y / cellSize)))

        guard let candidateZones = grid[cell] else {
            return nil
        }

        // Check each candidate zone
        return candidateZones.first { zone in
            zone.bounds.contains(point)
        }
    }
}
