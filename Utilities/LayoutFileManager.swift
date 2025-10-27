//
//  LayoutFileManager.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import Foundation

/// Manages loading, saving, and deleting layout files
/// Handles both local and iCloud storage locations
class LayoutFileManager {

    // MARK: - Properties

    static let shared = LayoutFileManager()

    private let fileExtension = "fancyareas"
    private let maxLayoutCount = 10

    /// Local storage directory
    private var localDirectory: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let fancyAreasDir = appSupport.appendingPathComponent("FancyAreas/Layouts", isDirectory: true)
        return fancyAreasDir
    }

    /// iCloud storage directory (if available)
    private var iCloudDirectory: URL? {
        guard let ubiquityURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            return nil
        }
        return ubiquityURL.appendingPathComponent("Documents/Layouts", isDirectory: true)
    }

    /// Current storage location based on preferences
    var storageDirectory: URL {
        // TODO: Check user preference for iCloud vs local
        // For now, always use local
        return localDirectory
    }

    // MARK: - Initialization

    private init() {
        createDirectoriesIfNeeded()
    }

    // MARK: - Public Methods

    /// Saves a layout to disk
    /// - Parameter layout: The layout to save
    /// - Throws: FileManagerError if save fails or limit reached
    func saveLayout(_ layout: Layout) throws {
        // Check layout limit
        let existingLayouts = try listLayouts()
        let existingLayoutIDs = Set(existingLayouts.map { $0.id })

        // If this is a new layout (not updating existing), check the limit
        if !existingLayoutIDs.contains(layout.id) && existingLayouts.count >= maxLayoutCount {
            throw FileManagerError.layoutLimitReached
        }

        // If updating existing layout, delete old file first (in case name changed)
        if existingLayoutIDs.contains(layout.id) {
            let allFiles = try listLayoutFiles()
            if let oldFileURL = allFiles.first(where: { $0.lastPathComponent.contains(layout.id.uuidString) }) {
                try? FileManager.default.removeItem(at: oldFileURL)
                print("✓ Removed old layout file: \(oldFileURL.lastPathComponent)")
            }
        }

        // Encode layout to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let jsonData = try encoder.encode(layout)

        // Create file URL
        let fileName = sanitizeFileName(layout.layoutName) + "-" + layout.id.uuidString + ".\(fileExtension)"
        let fileURL = storageDirectory.appendingPathComponent(fileName)

        // Write to disk
        try jsonData.write(to: fileURL, options: .atomic)

        print("✓ Layout saved: \(fileName)")
    }

    /// Loads a layout from disk
    /// - Parameter id: The UUID of the layout to load
    /// - Returns: The loaded layout
    /// - Throws: FileManagerError if load fails
    func loadLayout(id: UUID) throws -> Layout {
        let allFiles = try listLayoutFiles()

        // Find file matching this ID
        guard let fileURL = allFiles.first(where: { $0.lastPathComponent.contains(id.uuidString) }) else {
            throw FileManagerError.layoutNotFound
        }

        return try loadLayout(from: fileURL)
    }

    /// Loads a layout from a specific file URL
    /// - Parameter url: The file URL to load from
    /// - Returns: The loaded layout
    /// - Throws: FileManagerError if load fails
    func loadLayout(from url: URL) throws -> Layout {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw FileManagerError.fileNotFound
        }

        let jsonData = try Data(contentsOf: url)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let layout = try decoder.decode(Layout.self, from: jsonData)
            return layout
        } catch {
            throw FileManagerError.corruptedFile
        }
    }

    /// Lists all saved layouts
    /// - Returns: Array of layouts, sorted by modified date (newest first)
    /// - Throws: FileManagerError if listing fails
    func listLayouts() throws -> [Layout] {
        let fileURLs = try listLayoutFiles()

        var layoutsDict: [UUID: Layout] = [:]
        var filesToDelete: [URL] = []

        for fileURL in fileURLs {
            do {
                let layout = try loadLayout(from: fileURL)

                // If we already have this layout ID, keep the newer one
                if let existing = layoutsDict[layout.id] {
                    if layout.modified > existing.modified {
                        layoutsDict[layout.id] = layout
                        // Mark old file for deletion
                        if let oldURL = fileURLs.first(where: {
                            $0.lastPathComponent.contains(existing.id.uuidString) && $0 != fileURL
                        }) {
                            filesToDelete.append(oldURL)
                        }
                    } else {
                        // Current file is older, mark it for deletion
                        filesToDelete.append(fileURL)
                    }
                } else {
                    layoutsDict[layout.id] = layout
                }
            } catch {
                print("⚠️ Warning: Could not load layout from \(fileURL.lastPathComponent): \(error)")
                // Continue loading other layouts
            }
        }

        // Clean up duplicate files
        for fileURL in filesToDelete {
            try? FileManager.default.removeItem(at: fileURL)
            print("✓ Cleaned up duplicate: \(fileURL.lastPathComponent)")
        }

        // Sort by modified date (newest first)
        return Array(layoutsDict.values).sorted { $0.modified > $1.modified }
    }

    /// Deletes a layout file
    /// - Parameter id: The UUID of the layout to delete
    /// - Throws: FileManagerError if deletion fails
    func deleteLayout(id: UUID) throws {
        let allFiles = try listLayoutFiles()

        guard let fileURL = allFiles.first(where: { $0.lastPathComponent.contains(id.uuidString) }) else {
            throw FileManagerError.layoutNotFound
        }

        try FileManager.default.removeItem(at: fileURL)
        print("✓ Layout deleted: \(fileURL.lastPathComponent)")
    }

    /// Validates a layout file for integrity
    /// - Parameter url: The file URL to validate
    /// - Returns: True if valid, false otherwise
    func validateLayoutFile(at url: URL) -> Bool {
        do {
            _ = try loadLayout(from: url)
            return true
        } catch {
            return false
        }
    }

    // MARK: - Private Methods

    /// Creates storage directories if they don't exist
    private func createDirectoriesIfNeeded() {
        let directories = [localDirectory, iCloudDirectory].compactMap { $0 }

        for directory in directories {
            if !FileManager.default.fileExists(atPath: directory.path) {
                do {
                    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                    print("✓ Created directory: \(directory.path)")
                } catch {
                    print("⚠️ Failed to create directory: \(error)")
                }
            }
        }
    }

    /// Lists all layout files in the storage directory
    /// - Returns: Array of file URLs
    /// - Throws: Error if directory reading fails
    private func listLayoutFiles() throws -> [URL] {
        guard FileManager.default.fileExists(atPath: storageDirectory.path) else {
            return []
        }

        let files = try FileManager.default.contentsOfDirectory(
            at: storageDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )

        return files.filter { $0.pathExtension == fileExtension }
    }

    /// Sanitizes a filename by removing invalid characters
    /// - Parameter name: The original name
    /// - Returns: Sanitized filename
    private func sanitizeFileName(_ name: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        return name.components(separatedBy: invalidCharacters).joined(separator: "-")
    }
}

// MARK: - FileManagerError

enum FileManagerError: LocalizedError {
    case layoutLimitReached
    case layoutNotFound
    case fileNotFound
    case corruptedFile
    case storageFull
    case permissionDenied
    case iCloudUnavailable

    var errorDescription: String? {
        switch self {
        case .layoutLimitReached:
            return "Maximum of 10 layouts reached. Please delete a layout before creating a new one."
        case .layoutNotFound:
            return "The requested layout could not be found."
        case .fileNotFound:
            return "The layout file does not exist."
        case .corruptedFile:
            return "The layout file is corrupted and cannot be read."
        case .storageFull:
            return "Storage is full. Please free up space and try again."
        case .permissionDenied:
            return "Permission denied. Check file permissions and try again."
        case .iCloudUnavailable:
            return "iCloud is not available. Check your internet connection and iCloud settings."
        }
    }
}
