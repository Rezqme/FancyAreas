//
//  MonitorConfiguration.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import Foundation
import CoreGraphics

/// Represents the complete monitor setup configuration
/// Tracks all connected displays and their arrangement
struct MonitorConfiguration: Codable, Equatable {
    var displays: [Display]

    init(displays: [Display] = []) {
        self.displays = displays
    }

    /// Returns the primary display if one exists
    var primaryDisplay: Display? {
        displays.first { $0.isPrimary }
    }

    /// Returns the total number of displays
    var displayCount: Int {
        displays.count
    }

    /// Compares this configuration to another to check compatibility
    /// - Parameter other: The configuration to compare against
    /// - Returns: True if configurations are similar enough to adapt
    func isCompatible(with other: MonitorConfiguration) -> Bool {
        // Same number of displays
        guard displayCount == other.displayCount else { return false }

        // Check if display IDs match (exact match)
        let thisIDs = Set(displays.map { $0.displayID })
        let otherIDs = Set(other.displays.map { $0.displayID })

        return thisIDs == otherIDs
    }

    /// Checks if configurations are similar (same count and similar resolutions)
    /// - Parameter other: The configuration to compare against
    /// - Returns: True if configurations are similar
    func isSimilar(to other: MonitorConfiguration) -> Bool {
        guard displayCount == other.displayCount else { return false }

        // Check if resolutions are similar (within 10% tolerance)
        for (display, otherDisplay) in zip(displays.sorted(by: { $0.displayID < $1.displayID }),
                                            other.displays.sorted(by: { $0.displayID < $1.displayID })) {
            let widthDiff = abs(display.resolution.width - otherDisplay.resolution.width)
            let heightDiff = abs(display.resolution.height - otherDisplay.resolution.height)

            let widthTolerance = display.resolution.width * 0.1
            let heightTolerance = display.resolution.height * 0.1

            if widthDiff > widthTolerance || heightDiff > heightTolerance {
                return false
            }
        }

        return true
    }
}

/// Represents a single display/monitor
struct Display: Codable, Identifiable, Equatable {
    var id: String { displayID }
    var displayID: String
    var name: String
    var resolution: CGSize
    var position: CGPoint
    var isPrimary: Bool

    init(
        displayID: String,
        name: String,
        resolution: CGSize,
        position: CGPoint,
        isPrimary: Bool = false
    ) {
        self.displayID = displayID
        self.name = name
        self.resolution = resolution
        self.position = position
        self.isPrimary = isPrimary
    }

    /// Returns the frame (bounds) of this display
    var frame: CGRect {
        CGRect(origin: position, size: resolution)
    }
}
