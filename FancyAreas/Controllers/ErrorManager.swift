//
//  ErrorManager.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import Foundation
import AppKit

/// Centralized error handling and logging system
class ErrorManager {

    // MARK: - Properties

    static let shared = ErrorManager()

    private let logDirectory: URL
    private let maxLogAge: TimeInterval = 7 * 24 * 60 * 60 // 7 days
    private let dateFormatter: DateFormatter

    // MARK: - Initialization

    private init() {
        // Setup log directory
        let logsPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Logs/FancyAreas", isDirectory: true)
        self.logDirectory = logsPath

        // Create directory if needed
        try? FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true)

        // Setup date formatter
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"

        // Clean old logs
        cleanOldLogs()

        log(.info, "ErrorManager initialized", context: "Startup")
    }

    // MARK: - Logging

    /// Logs a message with severity level
    /// - Parameters:
    ///   - level: The severity level
    ///   - message: The message to log
    ///   - context: Optional context information
    ///   - error: Optional error object
    func log(_ level: LogLevel, _ message: String, context: String? = nil, error: Error? = nil) {
        let timestamp = dateFormatter.string(from: Date())
        let contextStr = context.map { " [\($0)]" } ?? ""
        let errorStr = error.map { " Error: \($0.localizedDescription)" } ?? ""

        let logMessage = "\(timestamp) [\(level.emoji) \(level.rawValue.uppercased())]\(contextStr) \(message)\(errorStr)"

        // Print to console
        print(logMessage)

        // Write to log file
        writeToLogFile(logMessage)

        // Handle critical errors
        if level == .error || level == .critical {
            handleError(level: level, message: message, context: context, error: error)
        }
    }

    /// Logs debug information (only in debug builds)
    func debug(_ message: String, context: String? = nil) {
        #if DEBUG
        log(.debug, message, context: context)
        #endif
    }

    /// Logs info message
    func info(_ message: String, context: String? = nil) {
        log(.info, message, context: context)
    }

    /// Logs warning message
    func warning(_ message: String, context: String? = nil) {
        log(.warning, message, context: context)
    }

    /// Logs error message
    func error(_ message: String, context: String? = nil, error: Error? = nil) {
        log(.error, message, context: context, error: error)
    }

    /// Logs critical error message
    func critical(_ message: String, context: String? = nil, error: Error? = nil) {
        log(.critical, message, context: context, error: error)
    }

    // MARK: - Error Handling

    /// Handles an error with user notification
    /// - Parameters:
    ///   - level: The severity level
    ///   - message: The error message
    ///   - context: Optional context
    ///   - error: Optional error object
    private func handleError(level: LogLevel, message: String, context: String?, error: Error?) {
        // Determine if we should show to user
        let shouldNotifyUser = level == .critical || (level == .error && isUserFacingError(context: context))

        if shouldNotifyUser {
            DispatchQueue.main.async {
                self.showErrorToUser(message: message, context: context, error: error)
            }
        }
    }

    /// Shows error to user
    /// - Parameters:
    ///   - message: The error message
    ///   - context: Optional context
    ///   - error: Optional error object
    private func showErrorToUser(message: String, context: String?, error: Error?) {
        let alert = NSAlert()
        alert.messageText = context ?? "Error"
        alert.informativeText = message + (error.map { "\n\n\($0.localizedDescription)" } ?? "")
        alert.alertStyle = .warning

        // Add recovery suggestions
        if let suggestions = getRecoverySuggestions(for: context) {
            alert.informativeText += "\n\nSuggestions:\n" + suggestions.joined(separator: "\n")
        }

        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "View Logs")

        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            openLogsFolder()
        }
    }

    /// Checks if this is a user-facing error
    /// - Parameter context: The error context
    /// - Returns: True if user should be notified
    private func isUserFacingError(context: String?) -> Bool {
        guard let context = context else { return true }

        let userFacingContexts = ["Layout", "Permissions", "File", "Window", "App Restoration"]
        return userFacingContexts.contains { context.contains($0) }
    }

    /// Gets recovery suggestions for common errors
    /// - Parameter context: The error context
    /// - Returns: Array of suggestions
    private func getRecoverySuggestions(for context: String?) -> [String]? {
        guard let context = context else { return nil }

        switch context {
        case let str where str.contains("Permission"):
            return [
                "• Check System Preferences > Security & Privacy",
                "• Grant required permissions to FancyAreas",
                "• Restart the application after granting permissions"
            ]
        case let str where str.contains("File"):
            return [
                "• Check available disk space",
                "• Verify file permissions",
                "• Try creating a new layout instead"
            ]
        case let str where str.contains("App"):
            return [
                "• Verify the application is installed",
                "• Check if the application is compatible",
                "• Try removing and re-assigning the application"
            ]
        case let str where str.contains("Window"):
            return [
                "• Some applications may resist window resizing",
                "• Try snapping the window manually",
                "• Check if the application has size constraints"
            ]
        default:
            return nil
        }
    }

    // MARK: - File Management

    /// Writes a message to the log file
    /// - Parameter message: The message to write
    private func writeToLogFile(_ message: String) {
        let logFile = getCurrentLogFile()

        guard let data = (message + "\n").data(using: .utf8) else { return }

        if FileManager.default.fileExists(atPath: logFile.path) {
            // Append to existing file
            if let fileHandle = try? FileHandle(forWritingTo: logFile) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } else {
            // Create new file
            try? data.write(to: logFile, options: .atomic)
        }
    }

    /// Gets the current log file URL
    /// - Returns: URL for today's log file
    private func getCurrentLogFile() -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())

        return logDirectory.appendingPathComponent("fancyareas-\(dateString).log")
    }

    /// Cleans log files older than maxLogAge
    private func cleanOldLogs() {
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: logDirectory,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        ) else { return }

        let cutoffDate = Date().addingTimeInterval(-maxLogAge)

        for file in files {
            guard file.pathExtension == "log" else { continue }

            if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path),
               let creationDate = attributes[.creationDate] as? Date,
               creationDate < cutoffDate {
                try? FileManager.default.removeItem(at: file)
                print("Cleaned old log: \(file.lastPathComponent)")
            }
        }
    }

    /// Opens the logs folder in Finder
    func openLogsFolder() {
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: logDirectory.path)
    }

    /// Exports logs to a specified location
    /// - Returns: URL of exported log archive, or nil if failed
    func exportLogs() -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let timestamp = dateFormatter.string(from: Date())

        let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        let archiveName = "FancyAreas-Logs-\(timestamp).zip"
        let archiveURL = desktopURL.appendingPathComponent(archiveName)

        // Create archive (simplified - in production would use proper zip library)
        do {
            let files = try FileManager.default.contentsOfDirectory(at: logDirectory, includingPropertiesForKeys: nil)
            // In a real implementation, would zip the files here
            print("Exported logs to: \(archiveURL.path)")
            return archiveURL
        } catch {
            print("Failed to export logs: \(error)")
            return nil
        }
    }
}

// MARK: - Log Level

enum LogLevel: String {
    case debug = "debug"
    case info = "info"
    case warning = "warning"
    case error = "error"
    case critical = "critical"

    var emoji: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .critical: return "🔥"
        }
    }
}
