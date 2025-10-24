# FancyAreas Architecture Documentation

Technical documentation for developers contributing to FancyAreas.

## Table of Contents

1. [Overview](#overview)
2. [Project Structure](#project-structure)
3. [Core Architecture](#core-architecture)
4. [Data Models](#data-models)
5. [Controllers](#controllers)
6. [Views](#views)
7. [Utilities](#utilities)
8. [Event Flow](#event-flow)
9. [Performance Optimizations](#performance-optimizations)
10. [Testing Strategy](#testing-strategy)
11. [Dependencies](#dependencies)
12. [Development Setup](#development-setup)

## Overview

FancyAreas is a macOS window management application built with Swift, SwiftUI, and AppKit. It enables users to define custom zones on their displays and snap windows into these zones using drag-and-drop with modifier keys.

### Key Technologies

- **Language**: Swift 5.9+
- **UI Frameworks**: SwiftUI (modern UI), AppKit/Cocoa (window management)
- **Build System**: Swift Package Manager
- **Minimum Target**: macOS 11.0 (Big Sur)
- **Architecture**: Universal Binary (Apple Silicon + Intel)

### Design Principles

1. **Performance First**: Zone detection <1ms, smooth 60fps animations
2. **User Privacy**: Zero telemetry, all processing local
3. **Accessibility**: Full VoiceOver support, keyboard navigation
4. **Simplicity**: Clean API, single responsibility per component
5. **Testability**: Comprehensive unit and integration tests

## Project Structure

```
FancyAreas/
├── FancyAreas/
│   ├── FancyAreasApp.swift          # Application entry point
│   ├── Models/                      # Data models
│   │   ├── Layout.swift             # Main layout structure
│   │   ├── Zone.swift               # Zone definition
│   │   ├── Display.swift            # Display information
│   │   ├── MonitorConfiguration.swift # Multi-monitor config
│   │   ├── AssignedApp.swift        # App-to-zone assignment
│   │   └── GridSettings.swift       # Grid customization
│   ├── Controllers/                 # Business logic
│   │   ├── ZoneManager.swift        # Zone detection engine
│   │   ├── WindowDragMonitor.swift  # Global event monitoring
│   │   ├── WindowSnapController.swift # Snap orchestration
│   │   ├── WindowSnapper.swift      # Window resizing/positioning
│   │   ├── PreferencesManager.swift # User preferences
│   │   ├── LayoutController.swift   # Layout activation
│   │   ├── MonitorManager.swift     # Display detection
│   │   ├── PermissionsManager.swift # Permission handling
│   │   ├── MenuBarController.swift  # Menu bar interface
│   │   ├── AppRestoration.swift     # App launch/positioning
│   │   ├── KeyboardShortcutManager.swift # Global shortcuts
│   │   ├── ErrorManager.swift       # Error handling/logging
│   │   └── NotificationManager.swift # User notifications
│   ├── Views/                       # User interface
│   │   ├── ZoneOverlayWindow.swift  # Transparent zone overlay
│   │   ├── PreferencesView.swift    # Settings UI
│   │   ├── LayoutManagementWindow.swift # Layout editor
│   │   ├── FirstRunSetupView.swift  # Setup wizard
│   │   └── LayoutPickerWindow.swift # Quick layout picker
│   ├── Utilities/                   # Helper classes
│   │   ├── LayoutFileManager.swift  # File I/O
│   │   ├── TemplateLibrary.swift    # Zone templates
│   │   └── AccessibilityHelper.swift # VoiceOver support
│   └── Resources/
│       ├── Info.plist               # App metadata
│       └── Assets.xcassets          # Icons/images
├── FancyAreasTests/                 # Test suite
│   ├── ModelTests.swift             # Data model tests
│   ├── ZoneDetectionTests.swift     # Zone logic tests
│   ├── FileManagerTests.swift       # I/O tests
│   ├── IntegrationTests.swift       # End-to-end tests
│   └── PerformanceTests.swift       # Benchmarks
├── docs/                            # Documentation
│   ├── ARCHITECTURE.md              # This file
│   ├── USER_GUIDE.md                # User documentation
│   ├── TROUBLESHOOTING.md           # Support guide
│   └── SHORTCUTS.md                 # Keyboard reference
├── Package.swift                    # SPM configuration
└── README.md                        # Project overview
```

## Core Architecture

### Application Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│                   FancyAreasApp.swift                       │
│                  (SwiftUI App Entry Point)                  │
└───────────────────┬─────────────────────────────────────────┘
                    │
        ┌───────────┴───────────┐
        │                       │
┌───────▼────────┐    ┌────────▼──────────┐
│ AppDelegate    │    │ MenuBarController │
│ (NSApplication │    │ (Status Bar Item) │
│  Delegate)     │    └───────────────────┘
└────────────────┘
```

**Initialization Flow**:
1. `FancyAreasApp` launches
2. `AppDelegate` set up for lifecycle events
3. `PermissionsManager` checks required permissions
4. If missing permissions → `FirstRunSetupView` presented
5. If permissions OK → `MenuBarController` initialized
6. Last active layout restored (if enabled)
7. Global event monitoring starts

### Component Communication

**Pattern**: Singleton + Delegate + Combine

```
┌──────────────────────────────────────────────────────────────┐
│                     Communication Flow                        │
└──────────────────────────────────────────────────────────────┘

WindowDragMonitor (Singleton)
    │
    │ (Delegate)
    ▼
WindowSnapController (Singleton)
    │
    ├─→ ZoneManager (Singleton)           # Zone detection
    ├─→ ZoneOverlayManager (Singleton)    # Visual overlay
    └─→ WindowSnapper (Singleton)         # Window control

PreferencesManager (Singleton + @Published)
    │
    │ (Combine @Published)
    ▼
SwiftUI Views                              # Auto-update UI
```

**Rationale**:
- **Singletons**: Natural fit for system-wide services (menu bar, event monitoring)
- **Delegates**: Loose coupling between event monitor and snap controller
- **Combine**: Reactive updates for preferences → UI binding

### Coordinate Systems

FancyAreas uses macOS screen coordinates:

```
┌────────────────────────────────────┐
│ (0,0)                              │  ← Origin: Top-left of primary display
│                                    │
│        Primary Display             │
│                                    │
│                              (w,h) │
└────────────────────────────────────┘
```

**Multi-Monitor**:
```
                    ┌──────────────┐
                    │ (1920, -1080)│  ← Display above primary
                    │   Display 2  │
                    │              │
                    └──────┬───────┘
┌────────────────┐         │
│ (0,0)          │         │
│   Display 1    ├─────────┘
│   (Primary)    │
└────────────────┘
```

**Key points**:
- Primary display origin is always (0, 0)
- Other displays positioned relative to primary
- Y-axis increases downward (standard macOS)
- All measurements in points (not pixels, for Retina support)

## Data Models

### Layout.swift

The root data structure for saved layouts.

```swift
struct Layout: Codable, Identifiable {
    var id: UUID                           // Unique identifier
    var layoutName: String                 // User-visible name
    var layoutType: LayoutType             // .zonesOnly or .zonesAndApps
    var created: Date                      // Creation timestamp
    var modified: Date                     // Last modification
    var tags: [String]                     // Optional categorization
    var monitorConfiguration: MonitorConfiguration  // Display setup
    var zones: [Zone]                      // Zone definitions
    var gridSettings: GridSettings         // Visual customization
}
```

**File Format**: JSON (.fancyareas extension)

**Example**:
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "layoutName": "Coding Setup",
  "layoutType": "zones_and_apps",
  "created": "2025-01-24T10:00:00Z",
  "modified": "2025-01-24T15:30:00Z",
  "tags": ["work", "development"],
  "monitorConfiguration": { ... },
  "zones": [ ... ],
  "gridSettings": { ... }
}
```

### Zone.swift

Individual zone within a layout.

```swift
struct Zone: Codable, Identifiable {
    var id: UUID                    // Unique identifier
    var zoneNumber: Int             // Display number (1-9)
    var displayID: String           // Which display this zone is on
    var bounds: CGRect              // Position and size
    var assignedApp: AssignedApp?   // Optional app assignment
}
```

**Bounds**: Uses screen coordinates
- `origin.x`: Distance from left edge of display
- `origin.y`: Distance from top edge of display
- `size.width`: Zone width
- `size.height`: Zone height

**Custom Codable**: CGRect not Codable by default, so we implemented:
```swift
extension CGRect: Codable {
    enum CodingKeys: String, CodingKey {
        case x, y, width, height
    }
    // encode/decode implementation
}
```

### MonitorConfiguration.swift

Captures display setup for layout compatibility checking.

```swift
struct MonitorConfiguration: Codable {
    var displays: [Display]
    var primaryDisplayID: String
    var created: Date

    func isCompatible(with other: MonitorConfiguration) -> Bool
    func isSimilar(to other: MonitorConfiguration) -> Bool
}
```

**Compatibility Logic**:
- `isCompatible`: Same count + same display IDs → safe to activate
- `isSimilar`: Same count + different IDs → warn user, allow activation

### Display.swift

Information about a single display.

```swift
struct Display: Codable, Identifiable {
    var id: UUID
    var displayID: String           // CoreGraphics ID (system-provided)
    var name: String                // User-friendly name
    var resolution: CGSize          // Width x Height in points
    var position: CGPoint           // Position in global coordinates
    var isPrimary: Bool             // Is this the primary display?
}
```

## Controllers

### ZoneManager.swift

**Responsibility**: Zone detection and layout management.

**Key Methods**:
```swift
class ZoneManager {
    static let shared = ZoneManager()

    // Activate a layout
    func activateLayout(_ layout: Layout)

    // Deactivate current layout
    func deactivateLayout()

    // Detect which zone contains a point
    func detectZone(at point: CGPoint, on displayID: String) -> Zone?

    // Get all zones for a display
    func getZones(for displayID: String) -> [Zone]
}
```

**Implementation Details**:

**Spatial Grid Optimization**:
```swift
private class SpatialGrid {
    private let cellSize: CGFloat = 100.0  // 100x100 point cells
    private var grid: [GridKey: [Zone]] = [:]

    init(zones: [Zone], displayBounds: CGRect) {
        for zone in zones {
            let cells = getCells(for: zone.bounds)
            for cell in cells {
                grid[cell, default: []].append(zone)
            }
        }
    }

    func findZone(at point: CGPoint) -> Zone? {
        let cell = GridKey(x: Int(point.x / cellSize),
                          y: Int(point.y / cellSize))
        guard let candidates = grid[cell] else { return nil }
        return candidates.first { $0.bounds.contains(point) }
    }
}
```

**Performance**: O(1) average case, O(k) worst case where k = zones per cell (typically 1-2)

### WindowDragMonitor.swift

**Responsibility**: Global mouse and keyboard event monitoring.

**Key Methods**:
```swift
class WindowDragMonitor {
    static let shared = WindowDragMonitor()
    weak var delegate: WindowDragMonitorDelegate?

    func startMonitoring()
    func stopMonitoring()
}

protocol WindowDragMonitorDelegate: AnyObject {
    func windowDragBegan(window: AXUIElement, at location: CGPoint)
    func windowDragMoved(window: AXUIElement, to location: CGPoint, modifierFlags: CGEventFlags)
    func windowDragModifiersChanged(window: AXUIElement, at location: CGPoint, modifierFlags: CGEventFlags)
    func windowDragEnded(window: AXUIElement, at location: CGPoint, modifierFlags: CGEventFlags)
}
```

**Implementation**: CGEventTap

```swift
private func createEventTap() -> CFMachPort? {
    let eventMask = (1 << CGEventType.leftMouseDown.rawValue) |
                    (1 << CGEventType.leftMouseDragged.rawValue) |
                    (1 << CGEventType.leftMouseUp.rawValue) |
                    (1 << CGEventType.flagsChanged.rawValue)

    return CGEvent.tapCreate(
        tap: .cgSessionEventTap,
        place: .headInsertEventTap,
        options: .defaultTap,
        eventsOfInterest: CGEventMask(eventMask),
        callback: eventTapCallback,
        userInfo: Unmanaged.passUnretained(self).toOpaque()
    )
}
```

**Event Flow**:
1. User clicks window title bar → `leftMouseDown` → detect dragged window
2. User drags → `leftMouseDragged` → report movement + modifiers
3. User presses/releases modifier → `flagsChanged` → update overlay
4. User releases mouse → `leftMouseUp` → snap if modifier held

**Permissions Required**: Screen Recording (to monitor global events)

### WindowSnapper.swift

**Responsibility**: Window resizing and positioning via Accessibility API.

**Key Methods**:
```swift
class WindowSnapper {
    static let shared = WindowSnapper()

    func snapWindow(_ window: AXUIElement, to zone: Zone, animated: Bool?) -> Bool
    func configureAnimation(enabled: Bool?, duration: TimeInterval?, respectReduceMotion: Bool?)
    func configureSpacing(edge: CGFloat?, zone: CGFloat?)
}
```

**Implementation**: AXUIElement manipulation

```swift
private func setWindowBounds(_ window: AXUIElement, to bounds: CGRect) -> Bool {
    // Set position
    var position = bounds.origin
    let positionValue = AXValueCreate(.cgPoint, &position)!
    let positionResult = AXUIElementSetAttributeValue(
        window,
        kAXPositionAttribute as CFString,
        positionValue
    )

    // Set size
    var size = bounds.size
    let sizeValue = AXValueCreate(.cgSize, &size)!
    let sizeResult = AXUIElementSetAttributeValue(
        window,
        kAXSizeAttribute as CFString,
        sizeValue
    )

    return positionResult == .success && sizeResult == .success
}
```

**Animation**: 60fps interpolation

```swift
private func animateWindow(_ window: AXUIElement, from fromBounds: CGRect, to toBounds: CGRect) {
    let steps = Int(animationDuration * 60)  // 60 FPS
    let delay = animationDuration / Double(steps)

    DispatchQueue.global(qos: .userInteractive).async {
        for step in 0...steps {
            let progress = CGFloat(step) / CGFloat(steps)
            let easedProgress = self.easeInOutQuad(progress)

            let currentBounds = self.interpolate(from: fromBounds, to: toBounds, progress: easedProgress)

            DispatchQueue.main.async {
                self.setWindowBounds(window, to: currentBounds)
            }

            if step < steps {
                Thread.sleep(forTimeInterval: delay)
            }
        }
    }
}
```

**Constraint Handling**:
- Respects app minimum size (`kAXMinSizeAttribute`)
- Respects app maximum size (`kAXMaxSizeAttribute`)
- Maintains aspect ratio if app requires it

**Permissions Required**: Accessibility

### PreferencesManager.swift

**Responsibility**: User preferences persistence and synchronization.

**Key Features**:
```swift
class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()

    // General
    @Published var modifierKey: ModifierKey
    @Published var animationDuration: TimeInterval
    @Published var animationEnabled: Bool
    @Published var respectReduceMotion: Bool

    // Appearance
    @Published var overlayOpacity: CGFloat
    @Published var showZoneNumbers: Bool
    @Published var borderWidth: CGFloat

    // Advanced
    @Published var launchOnLogin: Bool
    @Published var iCloudSyncEnabled: Bool
}
```

**Storage**:
- **Local**: UserDefaults
- **iCloud**: NSUbiquitousKeyValueStore (if sync enabled)

**Sync Logic**:
```swift
private func saveModifierKey() {
    let value = modifierKey.rawValue

    // Save locally
    UserDefaults.standard.set(value, forKey: "modifierKey")

    // Save to iCloud if enabled
    if iCloudSyncEnabled {
        NSUbiquitousKeyValueStore.default.set(value, forKey: "modifierKey")
        NSUbiquitousKeyValueStore.default.synchronize()
    }
}
```

**Apply Changes**:
```swift
@Published var modifierKey: ModifierKey {
    didSet {
        saveModifierKey()
        applyModifierKeyChange()  // Update WindowSnapController
    }
}

private func applyModifierKeyChange() {
    let flags = modifierKey.cgEventFlags
    WindowSnapController.shared.setRequiredModifier(flags)
}
```

### LayoutFileManager.swift

**Responsibility**: Reading and writing .fancyareas files.

**Key Methods**:
```swift
class LayoutFileManager {
    static let shared = LayoutFileManager()

    func saveLayout(_ layout: Layout) throws
    func loadLayout(id: UUID) throws -> Layout
    func listLayouts() throws -> [Layout]
    func deleteLayout(id: UUID) throws
}
```

**Storage Location**:
```swift
private var storageDirectory: URL {
    let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    let fancyAreasDir = appSupport.appendingPathComponent("FancyAreas/Layouts")
    try? FileManager.default.createDirectory(at: fancyAreasDir, withIntermediateDirectories: true)
    return fancyAreasDir
}
```

Result: `~/Library/Application Support/FancyAreas/Layouts/`

**File Naming**:
```swift
private func fileName(for layout: Layout) -> String {
    let sanitized = sanitizeFileName(layout.layoutName)
    return "\(sanitized)-\(layout.id.uuidString).fancyareas"
}
```

Example: `Coding-Setup-550e8400-e29b-41d4-a716-446655440000.fancyareas`

**Limit Enforcement**:
```swift
func saveLayout(_ layout: Layout) throws {
    let existing = try listLayouts()
    let existingIDs = Set(existing.map { $0.id })

    // Check if this is a new layout
    if !existingIDs.contains(layout.id) {
        // New layout - check limit
        if existing.count >= maxLayoutCount {
            throw FileManagerError.layoutLimitReached
        }
    }

    // ... save logic
}
```

## Views

### ZoneOverlayWindow.swift

**Responsibility**: Transparent overlay showing zones.

**Window Configuration**:
```swift
init(for screen: NSScreen) {
    super.init(
        contentRect: screen.frame,
        styleMask: [.borderless],
        backing: .buffered,
        defer: false,
        screen: screen
    )

    level = .floating              // Above all other windows
    backgroundColor = .clear        // Transparent background
    isOpaque = false               // Allow transparency
    hasShadow = false              // No shadow
    ignoresMouseEvents = true      // Click-through
    collectionBehavior = [
        .canJoinAllSpaces,         // Visible on all Spaces
        .stationary,               // Doesn't move
        .ignoresCycle              // Not in Cmd+Tab
    ]
}
```

**ZoneView**: Individual zone rendering

```swift
private class ZoneView: NSView {
    // Visual properties
    var overlayOpacity: CGFloat = 0.3
    var zoneColor: NSColor = .systemBlue
    var borderWidth: CGFloat = 2.0

    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = zoneColor.withAlphaComponent(overlayOpacity).cgColor
        layer?.borderColor = zoneColor.cgColor
        layer?.borderWidth = borderWidth
        layer?.cornerRadius = 4

        // Add zone number label
        if showZoneNumber {
            let label = NSTextField(labelWithString: "\(zone.zoneNumber)")
            label.font = NSFont.systemFont(ofSize: 48, weight: .bold)
            label.textColor = .white
            // Position in top-left corner
        }
    }
}
```

**Animation**:
```swift
func show() {
    alphaValue = 0
    orderFrontRegardless()

    NSAnimationContext.runAnimationGroup { context in
        context.duration = 0.1
        animator().alphaValue = 1.0
    }
}

func hide(completion: (() -> Void)? = nil) {
    NSAnimationContext.runAnimationGroup({ context in
        context.duration = 0.1
        animator().alphaValue = 0
    }, completionHandler: {
        self.orderOut(nil)
        completion?()
    })
}
```

### PreferencesView.swift

**Responsibility**: SwiftUI preferences interface.

**Structure**:
```swift
struct PreferencesView: View {
    @StateObject private var preferencesManager = PreferencesManager.shared

    var body: some View {
        TabView {
            GeneralPreferencesView()
                .tabItem { Label("General", systemImage: "gear") }
            AppearancePreferencesView()
                .tabItem { Label("Appearance", systemImage: "paintbrush") }
            AdvancedPreferencesView()
                .tabItem { Label("Advanced", systemImage: "slider.horizontal.3") }
            KeyboardShortcutsView()
                .tabItem { Label("Shortcuts", systemImage: "keyboard") }
        }
        .frame(width: 600, height: 500)
    }
}
```

**Binding Example**:
```swift
struct GeneralPreferencesView: View {
    @StateObject private var preferences = PreferencesManager.shared

    var body: some View {
        Form {
            Picker("Modifier key:", selection: $preferences.modifierKey) {
                Text("Command (⌘)").tag(ModifierKey.command)
                Text("Option (⌥)").tag(ModifierKey.option)
                Text("Control (⌃)").tag(ModifierKey.control)
                Text("Shift (⇧)").tag(ModifierKey.shift)
            }

            Slider(value: $preferences.animationDuration, in: 0.1...1.0) {
                Text("Animation duration: \(String(format: "%.1fs", preferences.animationDuration))")
            }

            Toggle("Enable animations", isOn: $preferences.animationEnabled)
        }
    }
}
```

**Why SwiftUI**: Modern, declarative, automatic view updates via @Published

### LayoutManagementWindow.swift

**Responsibility**: Layout editor with three-panel design.

**Structure**:
```swift
struct LayoutManagementWindow: View {
    @StateObject private var viewModel = LayoutManagementViewModel()

    var body: some View {
        HSplitView {
            // Left: Layout list
            layoutListPanel
                .frame(minWidth: 200, maxWidth: 300)

            // Center: Zone preview
            zonePreviewPanel
                .frame(minWidth: 400)

            // Right: Properties
            propertiesPanel
                .frame(minWidth: 250, maxWidth: 350)
        }
        .frame(minWidth: 900, minHeight: 600)
    }
}
```

**ViewModel Pattern**:
```swift
class LayoutManagementViewModel: ObservableObject {
    @Published var layouts: [Layout] = []
    @Published var selectedLayout: Layout?
    @Published var selectedZone: Zone?
    @Published var isEditing: Bool = false

    func loadLayouts() {
        layouts = (try? LayoutFileManager.shared.listLayouts()) ?? []
    }

    func activateLayout(_ layout: Layout) {
        LayoutController.shared.activateLayout(layout)
    }

    func deleteLayout(_ layout: Layout) {
        try? LayoutFileManager.shared.deleteLayout(id: layout.id)
        loadLayouts()
    }
}
```

## Utilities

### TemplateLibrary.swift

**Responsibility**: Built-in zone templates.

**Structure**:
```swift
struct ZoneTemplate {
    let name: String
    let description: String
    let category: TemplateCategory
    let preview: String
    let generator: (CGSize) -> [CGRect]
}

class TemplateLibrary {
    static let shared = TemplateLibrary()

    // Templates
    var twoColumnSplit: ZoneTemplate { ... }
    var threeColumnSplit: ZoneTemplate { ... }
    var grid2x2: ZoneTemplate { ... }
    // ... 7 more templates

    // Generate zones
    func generateZones(from template: ZoneTemplate, displayID: String, displaySize: CGSize) -> [Zone]
}
```

**Example Generator**:
```swift
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
```

### AccessibilityHelper.swift

**Responsibility**: VoiceOver and accessibility support.

**Key Methods**:
```swift
class AccessibilityHelper {
    static let shared = AccessibilityHelper()

    // Announce message to VoiceOver
    func announce(_ message: String)

    // Check if VoiceOver is running
    func isVoiceOverRunning() -> Bool

    // Get accessible color with contrast
    func accessibleColor(for background: NSColor) -> NSColor
}
```

**VoiceOver Announcements**:
```swift
func announce(_ message: String) {
    NSAccessibility.post(
        element: NSApp.mainWindow ?? NSApp,
        notification: .announcementRequested,
        userInfo: [
            .announcement: message,
            .priority: NSAccessibilityPriorityLevel.high
        ]
    )
}
```

**Usage Example**:
```swift
// When activating layout
AccessibilityHelper.shared.announce("Activated Coding Setup layout with 3 zones")

// When snapping window
AccessibilityHelper.shared.announce("Window snapped to zone 2")

// When showing overlay
AccessibilityHelper.shared.announce("Zone overlay visible. 4 zones available.")
```

## Event Flow

### Window Snapping Sequence

Complete flow from drag start to snap finish:

```
┌─────────────────────────────────────────────────────────────┐
│  1. User clicks and drags window title bar                  │
└───────────────────┬─────────────────────────────────────────┘
                    │
        ┌───────────▼─────────────┐
        │ WindowDragMonitor       │
        │ Detects leftMouseDown   │
        │ Identifies window       │
        └───────────┬─────────────┘
                    │ (delegate call)
                    ▼
        ┌───────────────────────────────────┐
        │ WindowSnapController              │
        │ windowDragBegan()                 │
        │ - Checks for active layout        │
        └───────────┬───────────────────────┘
                    │
┌───────────────────▼─────────────────────────────────────────┐
│  2. User drags window while holding modifier key            │
└───────────────────┬─────────────────────────────────────────┘
                    │
        ┌───────────▼─────────────┐
        │ WindowDragMonitor       │
        │ Detects flagsChanged    │
        │ + leftMouseDragged      │
        └───────────┬─────────────┘
                    │ (delegate call)
                    ▼
        ┌───────────────────────────────────┐
        │ WindowSnapController              │
        │ windowDragModifiersChanged()      │
        │ - Checks modifier key pressed     │
        │ - Calls showOverlay()             │
        └───────────┬───────────────────────┘
                    │
                    ├─→ ZoneOverlayManager.show(layout)
                    │   └─→ Creates ZoneOverlayWindow for each screen
                    │       └─→ Displays zones with animation
                    │
                    └─→ windowDragMoved()
                        └─→ detectAndHighlightZone(at: location)
                            └─→ ZoneManager.detectZone()
                                ├─→ SpatialGrid lookup (<1ms)
                                └─→ ZoneOverlayManager.highlightZone()
                                    └─→ Green highlight on zone

┌───────────────────────────────────────────────────────────┐
│  3. User releases mouse button                            │
└───────────────────┬───────────────────────────────────────┘
                    │
        ┌───────────▼─────────────┐
        │ WindowDragMonitor       │
        │ Detects leftMouseUp     │
        └───────────┬─────────────┘
                    │ (delegate call)
                    ▼
        ┌───────────────────────────────────┐
        │ WindowSnapController              │
        │ windowDragEnded()                 │
        │ - Check if modifier still held    │
        │ - Check if zone detected          │
        └───────────┬───────────────────────┘
                    │
                    ├─→ snapWindow(window, to: zone)
                    │   └─→ WindowSnapper.snapWindow()
                    │       ├─→ Get current window bounds
                    │       ├─→ Calculate target bounds
                    │       ├─→ Apply constraints (min/max size)
                    │       └─→ animateWindow() (60fps interpolation)
                    │
                    └─→ hideOverlay()
                        └─→ ZoneOverlayManager.hide()
                            └─→ Fade out animation
                            └─→ Remove overlay windows
```

**Timeline**:
- Drag start: 0ms
- Modifier pressed: varies
- Overlay appears: <100ms
- Zone detection: <1ms per movement
- Drag end: varies
- Snap animation: 100-1000ms (configurable)
- Overlay hide: <100ms

## Performance Optimizations

### Spatial Grid for Zone Detection

**Problem**: Linear search through zones is O(n), slow for many zones.

**Solution**: Spatial grid partitioning.

```
Display divided into 100x100 point cells:

┌─────┬─────┬─────┬─────┐
│ 0,0 │ 1,0 │ 2,0 │ 3,0 │
├─────┼─────┼─────┼─────┤   Each cell stores list of zones
│ 0,1 │ 1,1 │ 2,1 │ 3,1 │   that overlap it
├─────┼─────┼─────┼─────┤
│ 0,2 │ 1,2 │ 2,2 │ 3,2 │
└─────┴─────┴─────┴─────┘

Query: point (x, y)
1. Calculate cell: (x/100, y/100)
2. Look up zones in that cell
3. Check point containment for each zone

Complexity: O(1) average, O(k) worst case where k = zones per cell
```

**Performance**: <1ms for 20 zones on a 1920x1080 display.

### Animation on Background Thread

**Problem**: 60fps animation on main thread can block UI.

**Solution**: Interpolate on background thread, apply on main thread.

```swift
DispatchQueue.global(qos: .userInteractive).async {
    for step in 0...steps {
        let currentBounds = interpolate(...)

        // Apply on main thread
        DispatchQueue.main.async {
            self.setWindowBounds(window, to: currentBounds)
        }

        Thread.sleep(forTimeInterval: delay)
    }
}
```

**Result**: Smooth animation with no UI blocking.

### Lazy Loading Layouts

**Problem**: Loading all 10 layouts on startup is wasteful.

**Solution**: Load layout list (names only), load full layout data on demand.

```swift
func listLayouts() throws -> [Layout] {
    let urls = try FileManager.default.contentsOfDirectory(
        at: storageDirectory,
        includingPropertiesForKeys: [.nameKey, .contentModificationDateKey]
    )

    return try urls.compactMap { url -> Layout? in
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(Layout.self, from: data)
    }
}
```

**Optimization opportunity**: Cache layout summaries, load full data only when activating.

### Debouncing Zone Detection

**Problem**: Mouse moves generate many events per second.

**Solution**: Rate-limit zone detection updates.

```swift
private var lastDetectionTime: Date?
private let detectionInterval: TimeInterval = 0.016  // ~60 Hz

func detectAndHighlightZone(at location: CGPoint) {
    let now = Date()
    if let last = lastDetectionTime, now.timeIntervalSince(last) < detectionInterval {
        return  // Skip this update
    }
    lastDetectionTime = now

    // ... detection logic
}
```

**Result**: Reduces CPU usage during dragging.

## Testing Strategy

### Unit Tests

**Location**: `FancyAreasTests/`

**Coverage**:
- **Model Tests**: Codable encoding/decoding, compatibility checking
- **Zone Detection Tests**: Spatial grid accuracy, edge cases
- **File Manager Tests**: Save/load/delete/limit enforcement
- **Template Tests**: Generated zone validity

**Example**:
```swift
func testZoneDetection() {
    let zone = Zone(
        zoneNumber: 1,
        displayID: "test",
        bounds: CGRect(x: 0, y: 0, width: 100, height: 100)
    )

    let layout = Layout(/* ... zones: [zone] ... */)
    zoneManager.activateLayout(layout)

    // Test point inside zone
    let detectedZone = zoneManager.detectZone(at: CGPoint(x: 50, y: 50), on: "test")
    XCTAssertEqual(detectedZone?.id, zone.id)

    // Test point outside zone
    let noZone = zoneManager.detectZone(at: CGPoint(x: 150, y: 150), on: "test")
    XCTAssertNil(noZone)
}
```

### Integration Tests

**Location**: `FancyAreasTests/IntegrationTests.swift`

**Scenarios**:
- Complete layout workflow (create → save → load → activate → detect → delete)
- Template to layout conversion
- Preferences persistence
- Monitor configuration compatibility
- Error handling

**Example**:
```swift
func testCompleteLayoutWorkflow() {
    // 1. Create layout
    let layout = createTestLayout()

    // 2. Save
    XCTAssertNoThrow(try fileManager.saveLayout(layout))

    // 3. Load
    let loaded = try? fileManager.loadLayout(id: layout.id)
    XCTAssertNotNil(loaded)

    // 4. Activate
    zoneManager.activateLayout(loaded!)
    XCTAssertTrue(zoneManager.hasActiveLayout)

    // 5. Detect
    let zone = zoneManager.detectZone(at: CGPoint(x: 500, y: 500), on: "test")
    XCTAssertNotNil(zone)

    // 6. Delete
    XCTAssertNoThrow(try fileManager.deleteLayout(id: layout.id))
}
```

### Performance Tests

**Location**: `FancyAreasTests/PerformanceTests.swift`

**Benchmarks**:
- Zone detection: Target <1ms
- Layout activation: Target <500ms
- File save: Target <100ms
- File load: Target <100ms
- JSON encode/decode: Target <10ms

**Example**:
```swift
func testZoneDetectionPerformance() {
    zoneManager.activateLayout(testLayout)

    measure {
        for _ in 0..<1000 {
            let randomPoint = CGPoint(x: .random(in: 0...1920), y: .random(in: 0...1080))
            _ = zoneManager.detectZone(at: randomPoint, on: "test")
        }
    }
}
```

### Manual Testing

**Location**: `FancyAreasTests/IntegrationTests.swift` (commented checklist)

**Categories**:
- Platform testing (macOS versions, Apple Silicon vs Intel)
- Monitor configurations (single, dual, triple, hot-plug)
- Window snapping (all modifier keys, different apps)
- Zone overlay (appearance, animations, multi-monitor)
- Layout management (CRUD operations, limits)
- App restoration (launch, positioning, errors)
- Keyboard shortcuts (all shortcuts, conflicts)
- Permissions (first-run, missing, reset)
- Preferences (persistence, iCloud sync)
- Error handling (edge cases, invalid data)
- Accessibility (VoiceOver, keyboard-only)
- Performance (startup, memory, CPU)
- Edge cases (ultrawide displays, portrait mode, Split View)

## Dependencies

### System Frameworks

**AppKit / Cocoa**:
- `NSWindow`, `NSView`: Overlay windows and views
- `NSScreen`: Display detection
- `NSWorkspace`: App launching and detection
- `NSMenu`, `NSStatusBar`: Menu bar integration

**ApplicationServices**:
- `AXUIElement`: Window manipulation
- `CGEvent`, `CGEventTap`: Global event monitoring

**Combine**:
- `@Published`: Reactive preferences updates
- `ObservableObject`: ViewModel pattern

**SwiftUI**:
- Preferences UI
- Layout Management UI
- First-run setup wizard

**ServiceManagement**:
- `SMAppService`: Launch on login (macOS 13+)
- `LSSharedFileList`: Launch on login (macOS 11-12 fallback)

**UserNotifications**:
- `UNUserNotificationCenter`: System notifications
- Custom toast windows for lightweight notifications

**XCTest**:
- Unit tests
- Integration tests
- Performance benchmarks

### External Dependencies

**None**. FancyAreas has zero external dependencies for maximum stability and minimal attack surface.

## Development Setup

### Requirements

- **Xcode**: 14.0+
- **macOS**: 11.0+ (to build and run)
- **Swift**: 5.9+ (included with Xcode)

### Building

**Command Line**:
```bash
cd FancyAreas/FancyAreas
swift build
swift run
```

**Xcode**:
```bash
cd FancyAreas/FancyAreas
open Package.swift
```

Then press **Cmd+R** to build and run.

### Running Tests

**Command Line**:
```bash
swift test
```

**Xcode**:
Press **Cmd+U** to run all tests.

**Performance Tests**:
```bash
swift test --filter PerformanceTests
```

### Project Configuration

**Package.swift**:
```swift
let package = Package(
    name: "FancyAreas",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "FancyAreas", targets: ["FancyAreas"])
    ],
    targets: [
        .executableTarget(
            name: "FancyAreas",
            dependencies: [],
            path: "FancyAreas"
        ),
        .testTarget(
            name: "FancyAreasTests",
            dependencies: ["FancyAreas"],
            path: "FancyAreasTests"
        )
    ]
)
```

**Info.plist** (key entries):
```xml
<key>NSAccessibilityUsageDescription</key>
<string>FancyAreas needs Accessibility permission to control window positions.</string>

<key>NSScreenCaptureDescription</key>
<string>FancyAreas needs Screen Recording permission to detect window dragging.</string>

<key>LSUIElement</key>
<true/>  <!-- Menu bar app, no Dock icon -->
```

### Debugging

**Enable verbose logging**:
```swift
// In ErrorManager.swift
private let minLogLevel: LogLevel = .debug  // Change from .info
```

**View logs**:
```bash
tail -f ~/Library/Logs/FancyAreas/app.log
```

**Console.app**:
1. Open Console.app
2. Search for "FancyAreas"
3. View all system-level logs

**Breakpoints**:
- Set in Xcode as usual
- Pay attention to main thread vs background thread

### Code Style

**Swift Style Guide**:
- 4 spaces for indentation
- No trailing whitespace
- Descriptive variable names
- Comments for non-obvious logic
- Mark sections with `// MARK: -`

**Example**:
```swift
// MARK: - Properties

private let manager = ZoneManager.shared
private var isActive = false

// MARK: - Public Methods

/// Activates the specified layout
/// - Parameter layout: The layout to activate
/// - Returns: True if activation succeeded
func activate(_ layout: Layout) -> Bool {
    // Implementation
}

// MARK: - Private Methods

private func setupEventMonitoring() {
    // Implementation
}
```

---

## Contributing

See [README.md](../README.md) for contribution guidelines.

## License

FancyAreas is released under the MIT License. See [LICENSE](../LICENSE) for details.

---

**Questions?** Open an issue on [GitHub](https://github.com/your-org/FancyAreas/issues).

**Last Updated**: 2025-01-24
