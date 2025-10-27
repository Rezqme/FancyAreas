//
//  NotificationManager.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import Foundation
import AppKit
import UserNotifications

/// Manages user notifications and feedback
class NotificationManager: NSObject {

    // MARK: - Properties

    static let shared = NotificationManager()

    private let notificationCenter = UNUserNotificationCenter.current()

    // MARK: - Initialization

    private override init() {
        super.init()
        requestNotificationPermission()
    }

    // MARK: - Permission

    /// Requests notification permission
    private func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✓ Notification permission granted")
            } else if let error = error {
                print("⚠️ Notification permission error: \(error)")
            }
        }
    }

    // MARK: - Notifications

    /// Shows a notification
    /// - Parameters:
    ///   - title: Notification title
    ///   - message: Notification message
    ///   - type: Notification type
    func notify(title: String, message: String, type: NotificationType = .info) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = type.shouldPlaySound ? .default : nil

        // Add identifier based on type
        content.categoryIdentifier = type.rawValue

        // Create request
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Deliver immediately
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("⚠️ Failed to deliver notification: \(error)")
            }
        }
    }

    /// Shows a success notification
    /// - Parameters:
    ///   - title: Notification title
    ///   - message: Notification message
    func success(title: String, message: String) {
        notify(title: title, message: message, type: .success)
    }

    /// Shows an error notification
    /// - Parameters:
    ///   - title: Notification title
    ///   - message: Notification message
    func error(title: String, message: String) {
        notify(title: title, message: message, type: .error)
    }

    /// Shows a warning notification
    /// - Parameters:
    ///   - title: Notification title
    ///   - message: Notification message
    func warning(title: String, message: String) {
        notify(title: title, message: message, type: .warning)
    }

    /// Shows layout activated notification
    /// - Parameter layoutName: The name of the activated layout
    func layoutActivated(_ layoutName: String) {
        notify(
            title: "Layout Activated",
            message: "'\(layoutName)' is now active",
            type: .success
        )
    }

    /// Shows app restoration progress notification
    /// - Parameters:
    ///   - success: Number of successfully restored apps
    ///   - total: Total number of apps
    func appRestorationComplete(success: Int, total: Int) {
        let message = "\(success) of \(total) apps restored successfully"
        notify(
            title: "App Restoration Complete",
            message: message,
            type: success == total ? .success : .warning
        )
    }

    /// Shows permission required notification
    /// - Parameter permissionName: The name of the required permission
    func permissionRequired(_ permissionName: String) {
        notify(
            title: "Permission Required",
            message: "\(permissionName) permission is needed for this feature",
            type: .warning
        )
    }
}

// MARK: - In-App Toast Notifications

extension NotificationManager {

    /// Shows a brief in-app toast message
    /// - Parameters:
    ///   - message: The message to display
    ///   - duration: How long to show the toast
    func showToast(_ message: String, duration: TimeInterval = 2.0) {
        DispatchQueue.main.async {
            guard let screen = NSScreen.main else { return }

            // Create toast window
            let toastWindow = ToastWindow(message: message, screen: screen)
            toastWindow.show(duration: duration)
        }
    }
}

// MARK: - Progress Indicators

extension NotificationManager {

    /// Shows a progress window
    /// - Parameters:
    ///   - title: Progress window title
    ///   - message: Progress message
    /// - Returns: ProgressController for updating progress
    func showProgress(title: String, message: String) -> ProgressController {
        let controller = ProgressController(title: title, message: message)
        DispatchQueue.main.async {
            controller.show()
        }
        return controller
    }
}

// MARK: - Toast Window

private class ToastWindow: NSWindow {

    init(message: String, screen: NSScreen) {
        let width: CGFloat = 300
        let height: CGFloat = 60
        let padding: CGFloat = 20

        let x = screen.frame.midX - width / 2
        let y = screen.frame.minY + padding

        let frame = NSRect(x: x, y: y, width: width, height: height)

        super.init(
            contentRect: frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        setupWindow(message: message)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupWindow(message: String) {
        backgroundColor = .clear
        isOpaque = false
        level = .floating
        ignoresMouseEvents = true
        collectionBehavior = [.canJoinAllSpaces, .stationary]

        // Create content view
        let windowBounds = NSRect(x: 0, y: 0, width: frame.width, height: frame.height)
        let contentView = NSView(frame: windowBounds)
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.85).cgColor
        contentView.layer?.cornerRadius = 10

        // Add label
        let label = NSTextField(labelWithString: message)
        label.textColor = .white
        label.alignment = .center
        label.frame = windowBounds.insetBy(dx: 10, dy: 10)
        label.font = .systemFont(ofSize: 13)
        contentView.addSubview(label)

        self.contentView = contentView
        alphaValue = 0
    }

    func show(duration: TimeInterval) {
        makeKeyAndOrderFront(nil)

        // Fade in
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            animator().alphaValue = 1.0
        }, completionHandler: {
            // Wait, then fade out
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = 0.2
                    self.animator().alphaValue = 0
                }, completionHandler: {
                    self.close()
                })
            }
        })
    }
}

// MARK: - Progress Controller

class ProgressController {

    private var window: NSWindow?
    private var progressIndicator: NSProgressIndicator?
    private var messageLabel: NSTextField?

    let title: String
    var message: String

    init(title: String, message: String) {
        self.title = title
        self.message = message
    }

    func show() {
        guard let screen = NSScreen.main else { return }

        let width: CGFloat = 300
        let height: CGFloat = 100

        let x = screen.frame.midX - width / 2
        let y = screen.frame.midY - height / 2

        let frame = NSRect(x: x, y: y, width: width, height: height)

        let window = NSWindow(
            contentRect: frame,
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )

        window.title = title
        window.level = .modalPanel

        // Create content
        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: width, height: height))

        let label = NSTextField(labelWithString: message)
        label.isEditable = false
        label.isBordered = false
        label.backgroundColor = .clear
        label.frame = NSRect(x: 20, y: 50, width: width - 40, height: 20)
        contentView.addSubview(label)
        messageLabel = label

        let progress = NSProgressIndicator(frame: NSRect(x: 20, y: 20, width: width - 40, height: 20))
        progress.style = .bar
        progress.isIndeterminate = true
        progress.startAnimation(nil)
        contentView.addSubview(progress)
        progressIndicator = progress

        window.contentView = contentView
        window.center()
        window.makeKeyAndOrderFront(nil)

        self.window = window
    }

    func updateMessage(_ message: String) {
        self.message = message
        DispatchQueue.main.async {
            self.messageLabel?.stringValue = message
        }
    }

    func updateProgress(_ value: Double) {
        DispatchQueue.main.async {
            self.progressIndicator?.isIndeterminate = false
            self.progressIndicator?.doubleValue = value
        }
    }

    func close() {
        DispatchQueue.main.async {
            self.window?.close()
            self.window = nil
        }
    }
}

// MARK: - Notification Type

enum NotificationType: String {
    case info = "info"
    case success = "success"
    case warning = "warning"
    case error = "error"

    var shouldPlaySound: Bool {
        switch self {
        case .success, .error:
            return true
        case .info, .warning:
            return false
        }
    }
}
