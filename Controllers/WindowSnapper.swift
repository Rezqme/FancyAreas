//
//  WindowSnapper.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import Cocoa
import ApplicationServices

/// Handles window resizing and positioning using Accessibility API
/// Snaps windows to zone bounds with animation support
class WindowSnapper {

    // MARK: - Properties

    static let shared = WindowSnapper()

    // Animation configuration
    private var animationEnabled = true
    private var animationDuration: TimeInterval = 0.25
    private var respectReduceMotion = true

    // Spacing configuration
    private var edgeSpacing: CGFloat = 0 // Spacing from screen edges
    private var zoneSpacing: CGFloat = 0 // Spacing between zones

    // MARK: - Public Methods

    /// Snaps a window to a zone's bounds
    /// - Parameters:
    ///   - window: The window element to snap
    ///   - zone: The target zone
    ///   - animated: Whether to animate the transition
    /// - Returns: True if snap was successful
    @discardableResult
    func snapWindow(_ window: AXUIElement, to zone: Zone, animated: Bool? = nil) -> Bool {
        // Get current window bounds
        guard let currentBounds = getWindowBounds(window) else {
            print("⚠️ Failed to get window bounds")
            return false
        }

        // Calculate target bounds with spacing
        let targetBounds = calculateTargetBounds(for: zone)

        // Check if app has minimum/maximum size constraints
        let constrainedBounds = applyWindowConstraints(window, targetBounds: targetBounds)

        // Determine if animation should be used
        let shouldAnimate: Bool
        if let animated = animated {
            shouldAnimate = animated && animationEnabled
        } else {
            shouldAnimate = animationEnabled && !isReduceMotionEnabled()
        }

        // Perform snap
        if shouldAnimate {
            animateWindow(window, from: currentBounds, to: constrainedBounds)
        } else {
            setWindowBounds(window, to: constrainedBounds)
        }

        print("✓ Window snapped to zone \(zone.zoneNumber)")
        return true
    }

    /// Sets animation configuration
    /// - Parameters:
    ///   - enabled: Whether animation is enabled
    ///   - duration: Animation duration in seconds
    ///   - respectReduceMotion: Whether to respect system Reduce Motion setting
    func configureAnimation(enabled: Bool? = nil, duration: TimeInterval? = nil, respectReduceMotion: Bool? = nil) {
        if let enabled = enabled {
            self.animationEnabled = enabled
        }
        if let duration = duration {
            self.animationDuration = duration
        }
        if let respectReduceMotion = respectReduceMotion {
            self.respectReduceMotion = respectReduceMotion
        }
    }

    /// Sets spacing configuration
    /// - Parameters:
    ///   - edge: Spacing from screen edges
    ///   - zone: Spacing between zones
    func configureSpacing(edge: CGFloat? = nil, zone: CGFloat? = nil) {
        if let edge = edge {
            self.edgeSpacing = edge
        }
        if let zone = zone {
            self.zoneSpacing = zone
        }
    }

    // MARK: - Private Methods

    /// Gets the current bounds of a window
    /// - Parameter window: The window element
    /// - Returns: The window bounds, or nil if unavailable
    private func getWindowBounds(_ window: AXUIElement) -> CGRect? {
        var positionValue: CFTypeRef?
        var sizeValue: CFTypeRef?

        guard AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &positionValue) == .success,
              AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeValue) == .success else {
            return nil
        }

        var position = CGPoint.zero
        var size = CGSize.zero

        if let positionValue = positionValue {
            AXValueGetValue(positionValue as! AXValue, .cgPoint, &position)
        }

        if let sizeValue = sizeValue {
            AXValueGetValue(sizeValue as! AXValue, .cgSize, &size)
        }

        return CGRect(origin: position, size: size)
    }

    /// Sets the bounds of a window
    /// - Parameters:
    ///   - window: The window element
    ///   - bounds: The target bounds
    /// - Returns: True if successful
    @discardableResult
    private func setWindowBounds(_ window: AXUIElement, to bounds: CGRect) -> Bool {
        // Set position
        var position = bounds.origin
        let positionValue = AXValueCreate(.cgPoint, &position)!
        let positionResult = AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, positionValue)

        // Set size
        var size = bounds.size
        let sizeValue = AXValueCreate(.cgSize, &size)!
        let sizeResult = AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue)

        return positionResult == .success && sizeResult == .success
    }

    /// Animates a window from one bounds to another
    /// - Parameters:
    ///   - window: The window element
    ///   - fromBounds: The starting bounds
    ///   - toBounds: The target bounds
    private func animateWindow(_ window: AXUIElement, from fromBounds: CGRect, to toBounds: CGRect) {
        let steps = Int(animationDuration * 60) // 60 FPS
        let delay = animationDuration / Double(steps)

        DispatchQueue.global(qos: .userInteractive).async {
            for step in 0...steps {
                let progress = CGFloat(step) / CGFloat(steps)
                let easedProgress = self.easeInOutQuad(progress)

                // Interpolate bounds
                let currentX = fromBounds.origin.x + (toBounds.origin.x - fromBounds.origin.x) * easedProgress
                let currentY = fromBounds.origin.y + (toBounds.origin.y - fromBounds.origin.y) * easedProgress
                let currentWidth = fromBounds.size.width + (toBounds.size.width - fromBounds.size.width) * easedProgress
                let currentHeight = fromBounds.size.height + (toBounds.size.height - fromBounds.size.height) * easedProgress

                let currentBounds = CGRect(x: currentX, y: currentY, width: currentWidth, height: currentHeight)

                // Set bounds on main thread
                DispatchQueue.main.async {
                    self.setWindowBounds(window, to: currentBounds)
                }

                if step < steps {
                    Thread.sleep(forTimeInterval: delay)
                }
            }
        }
    }

    /// Easing function for smooth animation
    /// - Parameter t: Progress (0-1)
    /// - Returns: Eased progress (0-1)
    private func easeInOutQuad(_ t: CGFloat) -> CGFloat {
        return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t
    }

    /// Calculates target bounds with spacing applied
    /// - Parameter zone: The target zone
    /// - Returns: Bounds with spacing applied
    private func calculateTargetBounds(for zone: Zone) -> CGRect {
        var bounds = zone.bounds

        // Apply spacing
        bounds.origin.x += zoneSpacing / 2
        bounds.origin.y += zoneSpacing / 2
        bounds.size.width -= zoneSpacing
        bounds.size.height -= zoneSpacing

        return bounds
    }

    /// Applies window size constraints
    /// - Parameters:
    ///   - window: The window element
    ///   - targetBounds: The desired bounds
    /// - Returns: Constrained bounds
    private func applyWindowConstraints(_ window: AXUIElement, targetBounds: CGRect) -> CGRect {
        var bounds = targetBounds

        // Get minimum size
        if let minSize = getWindowMinSize(window) {
            bounds.size.width = max(bounds.size.width, minSize.width)
            bounds.size.height = max(bounds.size.height, minSize.height)
        }

        // Get maximum size
        if let maxSize = getWindowMaxSize(window) {
            bounds.size.width = min(bounds.size.width, maxSize.width)
            bounds.size.height = min(bounds.size.height, maxSize.height)
        }

        return bounds
    }

    /// Gets the minimum size for a window
    /// - Parameter window: The window element
    /// - Returns: Minimum size, or nil
    private func getWindowMinSize(_ window: AXUIElement) -> CGSize? {
        var sizeValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(window, kAXMinSizeAttribute as CFString, &sizeValue) == .success else {
            return nil
        }

        var size = CGSize.zero
        if let sizeValue = sizeValue {
            AXValueGetValue(sizeValue as! AXValue, .cgSize, &size)
        }

        return size
    }

    /// Gets the maximum size for a window
    /// - Parameter window: The window element
    /// - Returns: Maximum size, or nil
    private func getWindowMaxSize(_ window: AXUIElement) -> CGSize? {
        var sizeValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(window, kAXMaxSizeAttribute as CFString, &sizeValue) == .success else {
            return nil
        }

        var size = CGSize.zero
        if let sizeValue = sizeValue {
            AXValueGetValue(sizeValue as! AXValue, .cgSize, &size)
        }

        return size
    }

    /// Checks if Reduce Motion is enabled in System Preferences
    /// - Returns: True if Reduce Motion is enabled
    private func isReduceMotionEnabled() -> Bool {
        guard respectReduceMotion else { return false }
        return NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
    }

    /// Gets information about a window for debugging
    /// - Parameter window: The window element
    /// - Returns: Dictionary of window properties
    func getWindowInfo(_ window: AXUIElement) -> [String: Any] {
        var info: [String: Any] = [:]

        // Title
        var titleValue: CFTypeRef?
        if AXUIElementCopyAttributeValue(window, kAXTitleAttribute as CFString, &titleValue) == .success,
           let title = titleValue as? String {
            info["title"] = title
        }

        // Role
        var roleValue: CFTypeRef?
        if AXUIElementCopyAttributeValue(window, kAXRoleAttribute as CFString, &roleValue) == .success,
           let role = roleValue as? String {
            info["role"] = role
        }

        // Subrole
        var subroleValue: CFTypeRef?
        if AXUIElementCopyAttributeValue(window, kAXSubroleAttribute as CFString, &subroleValue) == .success,
           let subrole = subroleValue as? String {
            info["subrole"] = subrole
        }

        // Bounds
        if let bounds = getWindowBounds(window) {
            info["bounds"] = bounds
        }

        // Min/Max size
        if let minSize = getWindowMinSize(window) {
            info["minSize"] = minSize
        }
        if let maxSize = getWindowMaxSize(window) {
            info["maxSize"] = maxSize
        }

        return info
    }
}
