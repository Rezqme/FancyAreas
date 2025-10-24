//
//  AssignedApp.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import Foundation

/// Represents an application assigned to a zone
/// Used for "Zones + Apps" layout type
struct AssignedApp: Codable, Equatable {
    var bundleID: String
    var appName: String
    var windowTitle: String?

    init(
        bundleID: String,
        appName: String,
        windowTitle: String? = nil
    ) {
        self.bundleID = bundleID
        self.appName = appName
        self.windowTitle = windowTitle
    }

    /// Returns a display name for the assigned app
    var displayName: String {
        if let title = windowTitle, !title.isEmpty {
            return "\(appName) - \(title)"
        }
        return appName
    }
}
