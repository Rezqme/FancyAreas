//
//  ZoneOverlayWindow.swift
//  FancyAreas
//
//  Created by Claude
//  Copyright © 2025 FancyAreas. All rights reserved.
//

import Cocoa

/// A transparent overlay window that displays zone rectangles
/// Appears on top of all other windows when modifier key is pressed
class ZoneOverlayWindow: NSWindow {

    // MARK: - Properties

    private var zoneViews: [ZoneView] = []
    private var currentLayout: Layout?

    // Visual configuration
    private var overlayOpacity: CGFloat = 0.3
    private var zoneColor: NSColor = .systemBlue
    private var activeZoneColor: NSColor = .systemGreen
    private var borderWidth: CGFloat = 2.0
    private var showZoneNumbers: Bool = true
    private var animationDuration: TimeInterval = 0.1

    // MARK: - Initialization

    init(for screen: NSScreen) {
        // Create full-screen frame
        let frame = screen.frame

        super.init(
            contentRect: frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false,
            screen: screen
        )

        setupWindow()
    }

    // MARK: - Public Methods

    /// Displays zones from a layout
    /// - Parameter layout: The layout containing zones to display
    func displayZones(from layout: Layout) {
        currentLayout = layout

        // Clear existing views
        clearZoneViews()

        // Get zones for this screen's display ID
        // TODO: Implement proper display ID mapping (Task 21)
        let displayID = "primary"
        let zones = layout.zones.filter { $0.displayID == displayID }

        // Create views for each zone
        for zone in zones {
            let zoneView = ZoneView(zone: zone, showNumber: showZoneNumbers)
            zoneView.overlayOpacity = overlayOpacity
            zoneView.zoneColor = zoneColor
            zoneView.borderWidth = borderWidth

            contentView?.addSubview(zoneView)
            zoneViews.append(zoneView)
        }

        print("✓ Displaying \(zones.count) zones")
    }

    /// Highlights a specific zone
    /// - Parameter zone: The zone to highlight, or nil to clear highlight
    func highlightZone(_ zone: Zone?) {
        for zoneView in zoneViews {
            if let zone = zone, zoneView.zone.id == zone.id {
                zoneView.setHighlighted(true, animated: true)
            } else {
                zoneView.setHighlighted(false, animated: true)
            }
        }
    }

    /// Shows the overlay with animation
    func show() {
        alphaValue = 0
        orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = animationDuration
            animator().alphaValue = 1.0
        }
    }

    /// Hides the overlay with animation
    func hide(completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = animationDuration
            animator().alphaValue = 0
        }, completionHandler: {
            self.orderOut(nil)
            completion?()
        })
    }

    /// Updates visual configuration
    /// - Parameters:
    ///   - opacity: Overlay opacity (0-1)
    ///   - showNumbers: Whether to show zone numbers
    func updateConfiguration(opacity: CGFloat? = nil, showNumbers: Bool? = nil) {
        if let opacity = opacity {
            self.overlayOpacity = opacity
            zoneViews.forEach { $0.overlayOpacity = opacity }
        }

        if let showNumbers = showNumbers {
            self.showZoneNumbers = showNumbers
            zoneViews.forEach { $0.showZoneNumber = showNumbers }
        }
    }

    // MARK: - Private Methods

    /// Sets up the window properties
    private func setupWindow() {
        // Window configuration
        level = .floating
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        ignoresMouseEvents = true
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]

        // Content view
        contentView = NSView(frame: frame)
        contentView?.wantsLayer = true
        contentView?.layer?.backgroundColor = NSColor.clear.cgColor

        // Initially hidden
        alphaValue = 0
    }

    /// Clears all zone views
    private func clearZoneViews() {
        zoneViews.forEach { $0.removeFromSuperview() }
        zoneViews.removeAll()
    }
}

// MARK: - ZoneView

/// A view that displays a single zone
private class ZoneView: NSView {

    // MARK: - Properties

    let zone: Zone
    var showZoneNumber: Bool
    var overlayOpacity: CGFloat = 0.3
    var zoneColor: NSColor = .systemBlue
    var borderWidth: CGFloat = 2.0

    private var isHighlighted = false
    private var numberLabel: NSTextField?

    // MARK: - Initialization

    init(zone: Zone, showNumber: Bool) {
        self.zone = zone
        self.showZoneNumber = showNumber

        super.init(frame: zone.bounds)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    /// Sets the highlighted state
    /// - Parameters:
    ///   - highlighted: Whether the zone should be highlighted
    ///   - animated: Whether to animate the change
    func setHighlighted(_ highlighted: Bool, animated: Bool) {
        guard highlighted != isHighlighted else { return }
        isHighlighted = highlighted

        let targetColor = highlighted ? NSColor.systemGreen : zoneColor
        let targetOpacity = highlighted ? overlayOpacity * 1.5 : overlayOpacity

        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.15
                layer?.backgroundColor = targetColor.withAlphaComponent(targetOpacity).cgColor
                layer?.borderColor = targetColor.cgColor
            }
        } else {
            layer?.backgroundColor = targetColor.withAlphaComponent(targetOpacity).cgColor
            layer?.borderColor = targetColor.cgColor
        }
    }

    // MARK: - Private Methods

    /// Sets up the view
    private func setupView() {
        wantsLayer = true

        // Zone background and border
        layer?.backgroundColor = zoneColor.withAlphaComponent(overlayOpacity).cgColor
        layer?.borderColor = zoneColor.cgColor
        layer?.borderWidth = borderWidth
        layer?.cornerRadius = 4

        // Zone number label
        if showZoneNumber {
            let label = NSTextField(labelWithString: "\(zone.zoneNumber)")
            label.font = NSFont.systemFont(ofSize: 48, weight: .bold)
            label.textColor = .white
            label.alignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false

            addSubview(label)

            // Position in top-left corner
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: topAnchor, constant: 20),
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                label.widthAnchor.constraint(equalToConstant: 80),
                label.heightAnchor.constraint(equalToConstant: 60)
            ])

            numberLabel = label
        }
    }
}

// MARK: - ZoneOverlayManager

/// Manages overlay windows across multiple displays
class ZoneOverlayManager {

    // MARK: - Properties

    static let shared = ZoneOverlayManager()

    private var overlayWindows: [NSScreen: ZoneOverlayWindow] = [:]
    private var isVisible = false

    // MARK: - Public Methods

    /// Shows zone overlays on all screens
    /// - Parameter layout: The layout to display
    func show(layout: Layout) {
        guard !isVisible else { return }

        // Create overlay for each screen
        for screen in NSScreen.screens {
            let overlay = ZoneOverlayWindow(for: screen)
            overlay.displayZones(from: layout)
            overlay.show()

            overlayWindows[screen] = overlay
        }

        isVisible = true
        print("✓ Zone overlays shown on \(NSScreen.screens.count) displays")
    }

    /// Hides all zone overlays
    func hide() {
        guard isVisible else { return }

        for (_, overlay) in overlayWindows {
            overlay.hide()
        }

        overlayWindows.removeAll()
        isVisible = false
        print("✓ Zone overlays hidden")
    }

    /// Highlights a zone on all displays
    /// - Parameter zone: The zone to highlight, or nil to clear
    func highlightZone(_ zone: Zone?) {
        for (_, overlay) in overlayWindows {
            overlay.highlightZone(zone)
        }
    }

    /// Updates configuration for all overlays
    /// - Parameters:
    ///   - opacity: Overlay opacity (0-1)
    ///   - showNumbers: Whether to show zone numbers
    func updateConfiguration(opacity: CGFloat? = nil, showNumbers: Bool? = nil) {
        for (_, overlay) in overlayWindows {
            overlay.updateConfiguration(opacity: opacity, showNumbers: showNumbers)
        }
    }

    /// Returns whether overlays are currently visible
    var isShowing: Bool {
        return isVisible
    }
}
