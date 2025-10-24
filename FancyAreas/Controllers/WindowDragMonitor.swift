//
//  WindowDragMonitor.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import Cocoa
import ApplicationServices

/// Monitors global window drag events using CGEventTap
/// Tracks mouse movements, modifier keys, and window being dragged
class WindowDragMonitor {

    // MARK: - Properties

    static let shared = WindowDragMonitor()

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var isMonitoring = false

    // Drag state
    private var isDragging = false
    private var draggedWindow: AXUIElement?
    private var dragStartLocation: CGPoint?
    private var currentMouseLocation: CGPoint?
    private var currentModifierFlags: CGEventFlags = []

    // Delegate for callbacks
    weak var delegate: WindowDragMonitorDelegate?

    // MARK: - Public Methods

    /// Starts monitoring window drag events
    func startMonitoring() {
        guard !isMonitoring else {
            print("⚠️ WindowDragMonitor already monitoring")
            return
        }

        // Check accessibility permission
        guard PermissionsManager.shared.checkAccessibilityPermission() else {
            print("⚠️ Accessibility permission required for WindowDragMonitor")
            PermissionsManager.shared.requestAccessibilityPermission()
            return
        }

        // Create event tap
        let eventMask = (1 << CGEventType.leftMouseDown.rawValue) |
                       (1 << CGEventType.leftMouseDragged.rawValue) |
                       (1 << CGEventType.leftMouseUp.rawValue) |
                       (1 << CGEventType.flagsChanged.rawValue)

        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passRetained(event) }
                let monitor = Unmanaged<WindowDragMonitor>.fromOpaque(refcon).takeUnretainedValue()
                return monitor.handleEvent(proxy: proxy, type: type, event: event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            print("⚠️ Failed to create event tap")
            return
        }

        self.eventTap = eventTap

        // Add to run loop
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)

        // Enable the event tap
        CGEvent.tapEnable(tap: eventTap, enable: true)

        isMonitoring = true
        print("✓ WindowDragMonitor started")
    }

    /// Stops monitoring window drag events
    func stopMonitoring() {
        guard isMonitoring else { return }

        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
        }

        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }

        eventTap = nil
        runLoopSource = nil
        isMonitoring = false

        print("✓ WindowDragMonitor stopped")
    }

    // MARK: - Private Methods

    /// Handles incoming events from the event tap
    /// - Returns: The event to pass through (or nil to consume)
    private func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        switch type {
        case .leftMouseDown:
            handleMouseDown(event: event)
        case .leftMouseDragged:
            handleMouseDragged(event: event)
        case .leftMouseUp:
            handleMouseUp(event: event)
        case .flagsChanged:
            handleFlagsChanged(event: event)
        default:
            break
        }

        // Always pass the event through (non-intrusive monitoring)
        return Unmanaged.passRetained(event)
    }

    /// Handles mouse down event
    private func handleMouseDown(event: CGEvent) {
        let location = event.location

        // Check if mouse is over a window title bar
        if let window = getWindowAtPoint(location) {
            // Check if click is on title bar
            if isPointInTitleBar(location, window: window) {
                isDragging = true
                draggedWindow = window
                dragStartLocation = location
                currentMouseLocation = location

                delegate?.windowDragBegan(window: window, at: location)
            }
        }
    }

    /// Handles mouse dragged event
    private func handleMouseDragged(event: CGEvent) {
        guard isDragging else { return }

        let location = event.location
        currentMouseLocation = location
        currentModifierFlags = event.flags

        // Notify delegate
        if let window = draggedWindow {
            delegate?.windowDragMoved(
                window: window,
                to: location,
                modifierFlags: currentModifierFlags
            )
        }
    }

    /// Handles mouse up event
    private func handleMouseUp(event: CGEvent) {
        guard isDragging else { return }

        let location = event.location

        // Notify delegate
        if let window = draggedWindow {
            delegate?.windowDragEnded(
                window: window,
                at: location,
                modifierFlags: currentModifierFlags
            )
        }

        // Reset drag state
        isDragging = false
        draggedWindow = nil
        dragStartLocation = nil
        currentMouseLocation = nil
    }

    /// Handles modifier key changes
    private func handleFlagsChanged(event: CGEvent) {
        let newFlags = event.flags
        let oldFlags = currentModifierFlags
        currentModifierFlags = newFlags

        // Only notify during drag
        guard isDragging, let window = draggedWindow, let location = currentMouseLocation else {
            return
        }

        // Check if modifier state changed
        if oldFlags != newFlags {
            delegate?.windowDragModifiersChanged(
                window: window,
                at: location,
                modifierFlags: newFlags
            )
        }
    }

    /// Gets the window at a specific point using Accessibility API
    /// - Parameter point: The point in screen coordinates
    /// - Returns: The AXUIElement representing the window, or nil
    private func getWindowAtPoint(_ point: CGPoint) -> AXUIElement? {
        var element: AXUIElement?
        let systemWide = AXUIElementCreateSystemWide()

        let result = AXUIElementCopyElementAtPosition(systemWide, Float(point.x), Float(point.y), &element)

        guard result == .success, let element = element else {
            return nil
        }

        // Try to get the window from the element
        return getWindowFromElement(element)
    }

    /// Gets the window element from any UI element
    /// - Parameter element: The starting UI element
    /// - Returns: The window element, or nil
    private func getWindowFromElement(_ element: AXUIElement) -> AXUIElement? {
        var current: AXUIElement? = element

        // Traverse up the hierarchy to find a window
        while let element = current {
            var role: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &role)

            if result == .success, let roleString = role as? String, roleString == kAXWindowRole as String {
                return element
            }

            // Get parent
            var parent: CFTypeRef?
            let parentResult = AXUIElementCopyAttributeValue(element, kAXParentAttribute as CFString, &parent)

            if parentResult == .success, let parentElement = parent {
                current = (parentElement as! AXUIElement)
            } else {
                break
            }
        }

        return nil
    }

    /// Checks if a point is in the title bar of a window
    /// - Parameters:
    ///   - point: The point to check
    ///   - window: The window element
    /// - Returns: True if point is in title bar
    private func isPointInTitleBar(_ point: CGPoint, window: AXUIElement) -> Bool {
        // Get window position and size
        var positionValue: CFTypeRef?
        var sizeValue: CFTypeRef?

        guard AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &positionValue) == .success,
              AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeValue) == .success else {
            return false
        }

        var position = CGPoint.zero
        var size = CGSize.zero

        if let positionValue = positionValue {
            AXValueGetValue(positionValue as! AXValue, .cgPoint, &position)
        }

        if let sizeValue = sizeValue {
            AXValueGetValue(sizeValue as! AXValue, .cgSize, &size)
        }

        // Title bar is typically the top ~22-28 pixels of the window
        let titleBarHeight: CGFloat = 28
        let titleBarRect = CGRect(x: position.x, y: position.y, width: size.width, height: titleBarHeight)

        return titleBarRect.contains(point)
    }

    /// Returns the current modifier flags
    var modifierFlags: CGEventFlags {
        return currentModifierFlags
    }

    /// Returns whether a drag is currently in progress
    var isDraggingWindow: Bool {
        return isDragging
    }
}

// MARK: - WindowDragMonitorDelegate

protocol WindowDragMonitorDelegate: AnyObject {
    /// Called when a window drag begins
    func windowDragBegan(window: AXUIElement, at location: CGPoint)

    /// Called as the window is being dragged
    func windowDragMoved(window: AXUIElement, to location: CGPoint, modifierFlags: CGEventFlags)

    /// Called when modifier keys change during drag
    func windowDragModifiersChanged(window: AXUIElement, at location: CGPoint, modifierFlags: CGEventFlags)

    /// Called when the window drag ends
    func windowDragEnded(window: AXUIElement, at location: CGPoint, modifierFlags: CGEventFlags)
}

// MARK: - CGEventFlags Extension

extension CGEventFlags {
    /// Returns true if Shift key is pressed
    var isShiftPressed: Bool {
        return contains(.maskShift)
    }

    /// Returns true if Control key is pressed
    var isControlPressed: Bool {
        return contains(.maskControl)
    }

    /// Returns true if Option key is pressed
    var isOptionPressed: Bool {
        return contains(.maskAlternate)
    }

    /// Returns true if Command key is pressed
    var isCommandPressed: Bool {
        return contains(.maskCommand)
    }

    /// Returns a human-readable description of the pressed modifiers
    var modifierDescription: String {
        var modifiers: [String] = []
        if isCommandPressed { modifiers.append("⌘") }
        if isOptionPressed { modifiers.append("⌥") }
        if isControlPressed { modifiers.append("⌃") }
        if isShiftPressed { modifiers.append("⇧") }
        return modifiers.isEmpty ? "None" : modifiers.joined(separator: " + ")
    }
}
