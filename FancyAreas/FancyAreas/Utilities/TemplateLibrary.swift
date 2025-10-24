//
//  TemplateLibrary.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import Foundation
import CoreGraphics

/// Provides built-in zone layout templates
class TemplateLibrary {

    static let shared = TemplateLibrary()

    private init() {}

    // MARK: - Template Definitions

    /// Returns all available templates
    var allTemplates: [ZoneTemplate] {
        return [
            twoColumnSplit,
            threeColumnSplit,
            twoRowSplit,
            threeRowSplit,
            focusLeft,
            focusRight,
            priorityGrid,
            sidebarLeft,
            sidebarRight,
            quadrants
        ]
    }

    // MARK: - Basic Templates

    var twoColumnSplit: ZoneTemplate {
        ZoneTemplate(
            name: "2 Column Split",
            description: "Two equal vertical columns (50/50)",
            category: .basic,
            preview: "⬜⬜"
        ) { size in
            let halfWidth = size.width / 2
            return [
                CGRect(x: 0, y: 0, width: halfWidth, height: size.height),
                CGRect(x: halfWidth, y: 0, width: halfWidth, height: size.height)
            ]
        }
    }

    var threeColumnSplit: ZoneTemplate {
        ZoneTemplate(
            name: "3 Column Split",
            description: "Three equal vertical columns (33/33/33)",
            category: .basic,
            preview: "⬜⬜⬜"
        ) { size in
            let thirdWidth = size.width / 3
            return [
                CGRect(x: 0, y: 0, width: thirdWidth, height: size.height),
                CGRect(x: thirdWidth, y: 0, width: thirdWidth, height: size.height),
                CGRect(x: thirdWidth * 2, y: 0, width: thirdWidth, height: size.height)
            ]
        }
    }

    var twoRowSplit: ZoneTemplate {
        ZoneTemplate(
            name: "2 Row Split",
            description: "Two equal horizontal rows (50/50)",
            category: .basic,
            preview: "🟦\n🟦"
        ) { size in
            let halfHeight = size.height / 2
            return [
                CGRect(x: 0, y: 0, width: size.width, height: halfHeight),
                CGRect(x: 0, y: halfHeight, width: size.width, height: halfHeight)
            ]
        }
    }

    var threeRowSplit: ZoneTemplate {
        ZoneTemplate(
            name: "3 Row Split",
            description: "Three equal horizontal rows (33/33/33)",
            category: .basic,
            preview: "🟦\n🟦\n🟦"
        ) { size in
            let thirdHeight = size.height / 3
            return [
                CGRect(x: 0, y: 0, width: size.width, height: thirdHeight),
                CGRect(x: 0, y: thirdHeight, width: size.width, height: thirdHeight),
                CGRect(x: 0, y: thirdHeight * 2, width: size.width, height: thirdHeight)
            ]
        }
    }

    // MARK: - Advanced Templates

    var focusLeft: ZoneTemplate {
        ZoneTemplate(
            name: "Focus Left",
            description: "Large left pane with small right sidebar (70/30)",
            category: .advanced,
            preview: "🟦⬜"
        ) { size in
            let leftWidth = size.width * 0.7
            let rightWidth = size.width * 0.3
            return [
                CGRect(x: 0, y: 0, width: leftWidth, height: size.height),
                CGRect(x: leftWidth, y: 0, width: rightWidth, height: size.height)
            ]
        }
    }

    var focusRight: ZoneTemplate {
        ZoneTemplate(
            name: "Focus Right",
            description: "Small left sidebar with large right pane (30/70)",
            category: .advanced,
            preview: "⬜🟦"
        ) { size in
            let leftWidth = size.width * 0.3
            let rightWidth = size.width * 0.7
            return [
                CGRect(x: 0, y: 0, width: leftWidth, height: size.height),
                CGRect(x: leftWidth, y: 0, width: rightWidth, height: size.height)
            ]
        }
    }

    var priorityGrid: ZoneTemplate {
        ZoneTemplate(
            name: "Priority Grid",
            description: "One large zone with four small corner zones",
            category: .advanced,
            preview: "⬜🟦⬜\n⬜🟦⬜"
        ) { size in
            let quarterWidth = size.width / 4
            let quarterHeight = size.height / 4
            let centerWidth = size.width / 2
            let centerHeight = size.height / 2

            return [
                // Center large zone
                CGRect(x: quarterWidth, y: quarterHeight, width: centerWidth, height: centerHeight),
                // Top-left
                CGRect(x: 0, y: 0, width: quarterWidth, height: quarterHeight),
                // Top-right
                CGRect(x: quarterWidth * 3, y: 0, width: quarterWidth, height: quarterHeight),
                // Bottom-left
                CGRect(x: 0, y: quarterHeight * 3, width: quarterWidth, height: quarterHeight),
                // Bottom-right
                CGRect(x: quarterWidth * 3, y: quarterHeight * 3, width: quarterWidth, height: quarterHeight)
            ]
        }
    }

    var sidebarLeft: ZoneTemplate {
        ZoneTemplate(
            name: "Sidebar Left",
            description: "Narrow left sidebar with main area (20/80)",
            category: .specialized,
            preview: "⬜🟦"
        ) { size in
            let sidebarWidth = size.width * 0.2
            let mainWidth = size.width * 0.8
            return [
                CGRect(x: 0, y: 0, width: sidebarWidth, height: size.height),
                CGRect(x: sidebarWidth, y: 0, width: mainWidth, height: size.height)
            ]
        }
    }

    var sidebarRight: ZoneTemplate {
        ZoneTemplate(
            name: "Sidebar Right",
            description: "Main area with narrow right sidebar (80/20)",
            category: .specialized,
            preview: "🟦⬜"
        ) { size in
            let mainWidth = size.width * 0.8
            let sidebarWidth = size.width * 0.2
            return [
                CGRect(x: 0, y: 0, width: mainWidth, height: size.height),
                CGRect(x: mainWidth, y: 0, width: sidebarWidth, height: size.height)
            ]
        }
    }

    var quadrants: ZoneTemplate {
        ZoneTemplate(
            name: "Quadrants",
            description: "Four equal quadrants (25% each)",
            category: .basic,
            preview: "⬜⬜\n⬜⬜"
        ) { size in
            let halfWidth = size.width / 2
            let halfHeight = size.height / 2
            return [
                CGRect(x: 0, y: 0, width: halfWidth, height: halfHeight),
                CGRect(x: halfWidth, y: 0, width: halfWidth, height: halfHeight),
                CGRect(x: 0, y: halfHeight, width: halfWidth, height: halfHeight),
                CGRect(x: halfWidth, y: halfHeight, width: halfWidth, height: halfHeight)
            ]
        }
    }

    // MARK: - Template Application

    /// Generates zones from a template for a specific display size
    /// - Parameters:
    ///   - template: The template to use
    ///   - displayID: The display ID for the zones
    ///   - displaySize: The size of the display
    /// - Returns: Array of zones generated from the template
    func generateZones(from template: ZoneTemplate, displayID: String, displaySize: CGSize) -> [Zone] {
        let bounds = template.generateZones(for: displaySize)

        return bounds.enumerated().map { (index, rect) in
            Zone(
                zoneNumber: index + 1,
                displayID: displayID,
                bounds: rect,
                assignedApp: nil
            )
        }
    }

    /// Gets templates for a specific category
    /// - Parameter category: The category to filter by
    /// - Returns: Templates in that category
    func templates(for category: TemplateCategory) -> [ZoneTemplate] {
        return allTemplates.filter { $0.category == category }
    }
}

// MARK: - Zone Template

struct ZoneTemplate {
    let name: String
    let description: String
    let category: TemplateCategory
    let preview: String
    let generator: (CGSize) -> [CGRect]

    /// Generates zone bounds for a given display size
    /// - Parameter size: The display size
    /// - Returns: Array of zone bounds
    func generateZones(for size: CGSize) -> [CGRect] {
        return generator(size)
    }
}

// MARK: - Template Category

enum TemplateCategory: String, CaseIterable {
    case basic = "Basic"
    case advanced = "Advanced"
    case specialized = "Specialized"
}
