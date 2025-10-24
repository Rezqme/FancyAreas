Create a new macOS application project named "FancyAreas" using Swift and SwiftUI/AppKit. Set up the project structure with:
- Minimum deployment target: macOS 11.0 (Big Sur)
- Universal binary support (Apple Silicon + Intel)
- Proper bundle identifier (com.yourcompany.fancyareas)
- App icon placeholders
- Basic Info.plist configuration
```

### Task 2: Core Data Models
```
Create the data models for FancyAreas:
1. Layout model (.fancyareas file format) with properties:
   - layoutName: String
   - layoutType: enum (zonesOnly, zonesAndApps)
   - created: Date
   - modified: Date
   - tags: [String]
   - monitorConfiguration: MonitorConfiguration
   - zones: [Zone]
   - gridSettings: GridSettings

2. Zone model with properties:
   - zoneNumber: Int
   - displayID: String
   - bounds: CGRect
   - assignedApp: AssignedApp? (optional)

3. MonitorConfiguration model with:
   - displays: [Display]

4. Display model with:
   - displayID: String
   - name: String
   - resolution: CGSize
   - position: CGPoint
   - isPrimary: Bool

5. AssignedApp model with:
   - bundleID: String
   - appName: String
   - windowTitle: String? (optional)

6. GridSettings model with:
   - columns: Int (1-12)
   - rows: Int (1-8)
   - spacing: Int (0-20px)

Implement Codable protocol for JSON serialization/deserialization.
```

### Task 3: File Management System
```
Create file management utilities:
1. LayoutFileManager class to handle:
   - Save layout to .fancyareas file
   - Load layout from .fancyareas file
   - Delete layout file
   - List all saved layouts (max 10)
   - Validate layout file integrity
   
2. Default storage locations:
   - Local: ~/Library/Application Support/FancyAreas/Layouts/
   - iCloud: iCloud Drive/FancyAreas/Layouts/ (if enabled)

3. Error handling for:
   - File corruption
   - Storage full
   - Permission denied
   - iCloud unavailable

4. Enforce 10 layout maximum limit
```

## Permissions & System Integration

### Task 4: Permission Management
```
Implement permission request and handling system:
1. Create PermissionsManager class to handle:
   - Accessibility permission check and request
   - Screen Recording permission check and request
   - Automation permission check and request

2. Display clear permission request dialogs explaining:
   - Why each permission is needed
   - What functionality requires it
   - Direct link to System Preferences > Privacy & Security

3. Graceful degradation:
   - Track which permissions are granted
   - Disable features that require missing permissions
   - Show persistent reminders when permissions missing
   - Allow app to function in limited capacity without all permissions

4. Create first-run setup flow to request permissions
```

### Task 5: Menu Bar Integration
```
Create menu bar (system tray) interface:
1. MenuBarController class with:
   - Status item icon (monochrome, template image)
   - Icon states: normal, active, no-layout
   - Light/dark mode support

2. Menu bar dropdown with:
   - Current active layout indicator (checkmark)
   - List of saved layouts (1-10) with:
     * Layout name
     * Type badge (zones-only vs zones+apps icon)
     * Monitor configuration badge
   - Separator
   - "New Layout..." menu item
   - "Edit Layouts..." menu item
   - "Preferences..." menu item
   - Separator
   - "Quit FancyAreas" menu item

3. Dynamic menu updates when layouts change
4. Keyboard shortcut support for menu actions
```

### Task 6: Launch on Login
```
Implement system startup integration:
1. Add launch on login toggle to preferences
2. Use SMLoginItemSetEnabled or modern ServiceManagement API
3. Handle enabling/disabling launch at login
4. Verify app launches correctly with system
5. Handle upgrades and permission changes
```

## Zone System Core

### Task 7: Zone Detection & Tracking
```
Create the zone snapping system core:
1. ZoneManager class to handle:
   - Store active zone layout
   - Calculate which zone contains a given point
   - Get zone bounds for window snapping
   - Handle multi-monitor zone configurations
   - Switch between zone layouts

2. Implement zone detection algorithm:
   - Given cursor coordinates, return zone number
   - Handle edge cases (cursor between zones)
   - Support for custom zone shapes
   - Multi-monitor boundary handling

3. Zone data structure optimizations for fast lookup
```

### Task 8: Window Drag Event Monitoring
```
Implement global window drag monitoring:
1. Create WindowDragMonitor class using:
   - CGEventTap for global mouse event monitoring
   - NSEvent for modifier key state tracking
   - Accessibility API for window identification

2. Track:
   - When window drag begins (mouse down on title bar)
   - Window position during drag
   - Modifier key state (Shift/Control/Option/Command)
   - When drag ends (mouse up)
   - Which window is being dragged

3. Handle permissions:
   - Check for Accessibility permission
   - Gracefully fail if permission denied
   - Show permission request if needed

4. Performance optimization:
   - Efficient event filtering
   - Minimize CPU usage during monitoring
```

### Task 9: Zone Overlay Display
```
Create the zone overlay visualization:
1. ZoneOverlayWindow class:
   - Frameless, transparent, full-screen window
   - Appears on all displays simultaneously
   - Semi-transparent zone rectangles
   - Zone borders (1-2px lines)
   - Optional zone numbers in corners
   - Active zone highlight (brighter color)

2. Overlay behavior:
   - Show when modifier key pressed during window drag
   - Hide when modifier key released
   - Smooth fade in/out animations (100ms)
   - Highlight zone under cursor
   - Respect "Reduce Motion" accessibility setting

3. Visual customization from preferences:
   - Overlay opacity (0-100%)
   - Zone colors
   - Show/hide zone numbers
   - Animation speed

4. Multi-monitor support:
   - Display correct zones on each screen
   - Handle different resolutions
   - Proper coordinate space conversions

5. Performance:
   - Overlay appears <100ms after modifier key press
   - Smooth 60fps updates while dragging
```

### Task 10: Window Snapping Engine
```
Implement window resizing and positioning:
1. WindowSnapper class to handle:
   - Detect when window should snap (drag ends in zone)
   - Calculate target window frame from zone bounds
   - Animate window to new position/size
   - Handle spacing/padding between zones
   - Respect app minimum/maximum window sizes

2. Animation options:
   - Instant (no animation)
   - Smooth animation (configurable duration)
   - System-respecting (honors Reduce Motion)

3. Use Accessibility API to:
   - Get window position/size
   - Set window position/size
   - Handle different window types
   - Manage app-specific behaviors

4. Error handling:
   - Window can't be resized (handle gracefully)
   - App doesn't respond to resize
   - Window smaller than zone (center or align)
   - App minimum size larger than zone
```

## Preferences & Settings

### Task 11: Preferences Window - General Tab
```
Create preferences window with General settings:
1. PreferencesWindow using SwiftUI or AppKit with sections:

2. Launch Settings:
   - "Launch on login" checkbox
   - Implementation connected to Task 6

3. Zone Snapping Behavior:
   - Modifier key selection dropdown (Shift/Control/Option/Command + combinations)
   - Zone overlay opacity slider (0-100%)
   - Snap sensitivity slider (how close to edge)
   - "Show zone numbers" checkbox
   - Animation speed dropdown (Off/Slow/Normal/Fast)

4. Window Behavior:
   - "Window follows the mouse" checkbox
   - Which window to pick radio buttons (front most / under cursor)
   - "Hide menu bar icon" checkbox

5. iCloud Integration:
   - "Sync preferences with iCloud" checkbox
   - Implementation for syncing via NSUbiquitousKeyValueStore

6. Keyboard Shortcuts:
   - Global shortcut recorder for opening layout picker
   - Shortcuts for layouts 1-10 (Cmd+Opt+1-0)
   - Customizable key combination input fields

7. Grid Settings (Default for new layouts):
   - Columns stepper (1-12)
   - Rows stepper (1-8)
   - Spacing stepper (0-20px)
   - Visual preview of grid

8. Dock Settings:
   - "Display Dock position" checkbox
   - Implementation to visualize dock in previews

9. System Actions:
   - "Reset all to defaults" button (red, destructive)
   - "Deactivate current license" button

10. Save preferences to UserDefaults
11. iCloud sync if enabled
```

### Task 12: Preferences Data Management
```
Create settings persistence system:
1. PreferencesManager class using:
   - UserDefaults for local preferences
   - NSUbiquitousKeyValueStore for iCloud sync
   - Codable structs for type-safe preferences

2. Settings to persist:
   - Launch on login
   - Modifier key configuration
   - Overlay opacity and appearance
   - Window behavior settings
   - Keyboard shortcuts
   - Grid defaults
   - iCloud sync enabled/disabled

3. Default values for first launch
4. Migration handling for app updates
5. Sync conflict resolution (last-write-wins)
6. Observers for preference changes
```

## Layout Management UI

### Task 13: Layout Management Window
```
Create the main layout management interface:
1. LayoutManagementWindow with three-panel design:

LEFT SIDEBAR (Layout List):
- Scrollable list view showing 1-10 layout slots
- Each item displays:
  * Layout name
  * Type badge (icon: zones-only vs zones+apps)
  * Monitor config (e.g., "2 displays")
  * Last modified date
- Empty slots shown as "Empty Slot +" 
- "New Layout" button at bottom (disabled if 10 exist)
- Selected layout highlighted

CENTER PANEL (Zone Preview):
- Large visual preview of selected layout
- Display zone boundaries and numbers
- Show app icons in zones (if zones+apps type)
- Grid overlay (if configured)
- Dock visualization (if enabled)
- Multi-monitor arrangement display

RIGHT PANEL (Properties):
- Layout name (editable text field)
- Layout type toggle: "Zones Only" ↔ "Zones + Apps"
- Monitor configuration details
- Zone count display
- Grid settings (if grid-based)
- Application assignments list (if zones+apps):
  * Zone number
  * Assigned app (with icon)
  * Remove/change app buttons

BOTTOM ACTION BAR:
- "Apply Layout" button (activates zone config)
- "Restore Apps" button (only for zones+apps, launches apps)
- "Edit Zones" button (opens zone editor)
- "Duplicate" button
- "Delete" button (requires confirmation)
- "Close" button

2. Connect to data models and file manager
3. Real-time updates when layouts change
4. Handle layout selection and preview updates
```

### Task 14: New Layout Creation Flow
```
Implement new layout creation:
1. "New Layout..." action from menu bar
2. Check if 10 layout limit reached
   - Show alert if limit reached
   - Prompt user to delete a layout first
3. Open Layout Management Window with Zone Editor
4. Initialize with default settings:
   - Default grid (from preferences)
   - "Zones Only" type
   - Current monitor configuration
   - Suggested name (e.g., "Layout 1", "Untitled Layout")
5. Allow user to configure zones and settings
6. Save on "Save Changes" click
7. Add to layout list (1-10)
8. Automatically make new layout active
```

### Task 15: Layout Editing
```
Implement layout editing functionality:
1. "Edit Zones" button opens Zone Editor (see Task 16)
2. In-place name editing in properties panel
3. Layout type toggle:
   - Switch between "Zones Only" and "Zones + Apps"
   - When switching to "Zones + Apps", enable app assignment
   - When switching to "Zones Only", optionally remove app assignments (confirm with user)
4. App assignment/removal:
   - "Assign Application" button per zone
   - Opens Application Picker (Task 17)
   - "Remove Assignment" button
   - Update zone preview with app icons
5. Layout duplication:
   - Create copy with " Copy" appended to name
   - Maintain all zone and app configurations
   - Check 10 layout limit before allowing
6. Layout deletion:
   - Confirmation dialog: "Are you sure you want to delete '[Layout Name]'? This cannot be undone."
   - Remove .fancyareas file
   - Update layout list
   - If deleted layout was active, deactivate
7. Save changes to file system
8. Update UI immediately
```

## Zone Editor

### Task 16: Zone Editor Implementation
```
Create interactive zone editing interface:
1. ZoneEditorWindow with components:

MAIN CANVAS:
- Visual representation of selected display(s)
- Draggable zone rectangles with handles
- Grid overlay (optional, toggleable)
- Snap guides when moving/resizing
- Zone numbers displayed
- Multi-monitor support (switch between displays)

LEFT TOOLBAR - Zone Templates:
- Template buttons:
  * 2 Columns
  * 3 Columns  
  * 2 Rows
  * 3 Rows
  * Focus + Sidebar (large + narrow)
  * Priority Grid (1 large + several small)
  * Custom grid (specify rows/columns dialog)
- One-click apply template to canvas

LEFT TOOLBAR - Drawing Tools:
- "Draw new zone" tool (click and drag)
- "Split zone" tool (divide existing)
- "Merge zones" tool (combine adjacent)
- "Delete zone" tool (remove selected)

RIGHT PANEL - Zone Properties (when zone selected):
- Zone number display
- Position (x, y coordinates)
- Size (width, height in px or %)
- App Assignment section (if zones+apps type):
  * "Assign Application" button
  * Currently assigned app with icon
  * "Remove Assignment" button

TOP TOOLBAR:
- Layout name (editable)
- Monitor selector dropdown (for multi-monitor)
- Grid controls:
  * Show/hide grid toggle
  * Snap to grid toggle  
  * Grid spacing input (px)
- Undo/Redo buttons

BOTTOM ACTION BAR:
- "Layout Type" toggle (Zones Only ↔ Zones + Apps)
- "Preview" button (shows zone overlay as it would appear)
- "Save Changes" button
- "Cancel" button

2. Implement zone manipulation:
- Click zone to select
- Drag zone to move
- Drag handles to resize
- Multi-select with Shift+Click
- Delete with Delete key
- Snap to grid (if enabled)
- Snap to other zones
- Alignment guides

3. Template application:
- Clear existing zones (with confirmation)
- Generate zones based on template
- Apply to selected display
- Adjust for display resolution

4. Zone validation:
- No overlapping zones
- All zones within display bounds
- Minimum zone size enforcement
- Warn if too many zones (performance)

5. Preview functionality:
- Show actual zone overlay on screen
- User can test snapping behavior
- Return to editor
```

### Task 17: Application Picker Dialog
```
Create application selection interface:
1. ApplicationPickerDialog modal window with:

SEARCH BAR:
- Text input field
- Filter applications by name in real-time

APPLICATION LIST:
- Recently used apps section (top)
- All installed applications (alphabetical)
- Each row displays:
  * App icon
  * App name  
  * App path (on hover tooltip)
- Scroll view for long lists
- Single selection

BROWSE BUTTON:
- Opens NSOpenPanel (Finder dialog)
- File type filter: .app bundles
- Allows selecting app not in list

ACTION BUTTONS:
- "Assign" button (primary, assigns selected app)
- "Cancel" button

2. Application discovery:
- Scan /Applications folder
- Scan /Applications/Utilities
- Scan ~/Applications
- Use NSWorkspace to find all apps
- Cache app list for performance
- Update cache periodically

3. Recently used tracking:
- Track last 10 assigned apps
- Store in UserDefaults
- Show at top of list

4. Return selected app info:
- Bundle identifier
- App name
- Icon (for display in zones)
```

## Layout Application & Restoration

### Task 18: Layout Activation (Zones Only)
```
Implement zone layout activation:
1. LayoutController class with:
   - Apply layout method
   - Store active layout reference
   - Update ZoneManager with new zones
   - Handle monitor configuration changes

2. When user selects layout from menu:
   - Load layout file
   - Check current monitor configuration
   - Warn if mismatch (optional dialog)
   - Set zones as active in ZoneManager
   - Update menu bar icon to show active state
   - Save as "last active layout" preference

3. Zone configuration becomes immediately active:
   - Zones available for snapping
   - Overlay shows new zones when modifier key pressed
   - Existing windows remain in place (not moved)

4. Monitor configuration handling:
   - If exact match: apply directly
   - If similar (same number of displays): offer to adapt
   - If different: warn user, allow to continue with adaptation
   - Scale zone positions if resolution differs
```

### Task 19: App Restoration (Zones + Apps)
```
Implement application launching and positioning:
1. AppRestoration class to handle:
   - Launch apps that aren't running
   - Position/resize apps that are running
   - Handle errors gracefully
   - Progress tracking

2. "Restore Apps" functionality:
   - Iterate through zones with assigned apps
   - For each assigned app:
     a. Check if app is running (NSWorkspace)
     b. If running:
        - Find app windows (Accessibility API)
        - Move/resize main window to zone bounds
     c. If not running:
        - Launch app (NSWorkspace.launchApplication)
        - Wait for app to finish launching (up to 10 seconds)
        - Position window when ready
     d. If app unavailable:
        - Log error
        - Continue to next app
        - Leave zone empty
     e. If app unresponsive:
        - Timeout after 10 seconds
        - Log error
        - Continue to next app

3. Progress indication:
   - Show progress dialog during restoration
   - Display current app being processed
   - Allow user to cancel
   - Show completion summary

4. Completion notification:
   - macOS notification center
   - Summary: "X of Y applications restored"
   - Click to see details/errors
   - Error log accessible from menu or notification

5. Error handling:
   - App not found: log bundle ID, suggest reinstall
   - App unresponsive: log timeout, suggest checking app
   - Permission denied: suggest granting automation permission
   - Window can't be resized: log app name, use best-fit
```

### Task 20: Non-Destructive Window Management
```
Ensure restoration doesn't close existing windows:
1. Window inventory before restoration:
   - Get list of all open windows (Accessibility API)
   - Store positions for safety

2. During restoration:
   - Only interact with assigned apps' windows
   - Leave other apps' windows untouched
   - Don't close any windows
   - If app already has windows open, reposition them
   - If app not open, launch it fresh

3. Additive approach:
   - Restored apps add to current workspace
   - Existing windows remain
   - User can manually close unwanted windows after
   - No automatic cleanup

4. Window identification:
   - Match windows by app bundle ID
   - For multi-window apps:
     * Use window title if specified in layout
     * Otherwise position main/first window
     * Other windows left as-is
```

## Multi-Monitor Support

### Task 21: Monitor Detection & Configuration
```
Implement multi-monitor support:
1. MonitorManager class to handle:
   - Detect all connected displays
   - Get display properties (resolution, position, ID)
   - Track display arrangement
   - Detect display changes (connect/disconnect)
   - Primary display identification

2. Use NSScreen API to:
   - Get all available screens
   - Monitor for NSApplication.didChangeScreenParametersNotification
   - Get screen frame and visible frame (excluding menu bar/dock)
   - Get screen backing properties (for Retina)

3. Display identification:
   - Use CGDirectDisplayID for stable IDs
   - Store display names (from IOKit)
   - Handle displays being unplugged/replugged
   - Match saved layouts to current config

4. Monitor configuration comparison:
   - Compare current setup to layout requirements
   - Detect matches (exact or similar)
   - Calculate adaptation if needed
   - Warn user of mismatches

5. Handle configuration changes:
   - Detect when monitors connected/disconnected
   - Update active layout if affected
   - Offer to switch to compatible layout
   - Remember layouts per configuration
```

### Task 22: Per-Display Zone Management
```
Implement independent zones per display:
1. Extend ZoneManager to support:
   - Zones mapped to specific display IDs
   - Multiple zone sets (one per display)
   - Query zones by display
   - Handle zones when display disconnects

2. Zone Editor multi-monitor support:
   - Display selector/switcher in toolbar
   - Show one display at a time in canvas
   - Separate zone configuration per display
   - Visual indicator of which display being edited
   - Preview all displays simultaneously (optional)

3. Zone Overlay multi-monitor:
   - Show overlay on all connected displays
   - Each display shows only its zones
   - Coordinate spaces handled correctly
   - Zone numbers unique across all displays (or per-display)

4. Window snapping across monitors:
   - Detect which display window is on
   - Use zones for that specific display
   - Handle window dragged across display boundary
   - Switch zone sets smoothly

5. Layout validation:
   - Check if all required displays present
   - Offer adaptation if displays missing
   - Scale zones if resolution changed
   - Maintain layout integrity
```

## Advanced Features

### Task 23: Keyboard Shortcuts System
```
Implement global keyboard shortcuts:
1. KeyboardShortcutManager class:
   - Register global hotkeys (using CGEventTap or Sauce)
   - Handle keyboard shortcut conflicts
   - User-customizable shortcuts
   - Enable/disable shortcuts

2. Default shortcuts:
   - Open layout picker: Cmd+Opt+Shift+L
   - Layout 1-10: Cmd+Opt+1 through Cmd+Opt+0
   - Toggle zone overlay: Cmd+Opt+Shift+Z
   - Open preferences: Cmd+,

3. Shortcut recorder UI:
   - Custom view for recording key combinations
   - Show current shortcut
   - Clear shortcut button
   - Conflict detection and warning
   - Validate shortcut (no system conflicts)

4. Actions triggered by shortcuts:
   - Switch to specific layout
   - Open layout picker (quick switcher)
   - Toggle zone overlay (without dragging)
   - Open preferences
```

### Task 24: iCloud Sync Implementation
```
Implement iCloud synchronization:
1. iCloudSyncManager class using:
   - NSUbiquitousKeyValueStore for preferences
   - NSFileManager ubiquityContainerURL for files
   - NSMetadataQuery for file monitoring

2. Sync preferences:
   - All settings from PreferencesManager
   - Last active layout per device
   - Recently used apps
   - Sync on change, debounced (5 second delay)

3. Sync layout files:
   - Store .fancyareas files in iCloud Drive
   - Monitor folder for changes
   - Download new/updated layouts automatically
   - Upload local changes
   - Conflict resolution (last-write-wins)
   - Handle iCloud unavailable gracefully

4. User settings:
   - Toggle in preferences to enable/disable
   - Choose local vs iCloud storage
   - Status indicator (syncing/synced/error)
   - Manual sync trigger

5. Multi-device coordination:
   - Layout library synced across devices
   - Device-specific layouts marked (optional metadata)
   - Smart suggestions (layouts for current monitor config)
   - Conflict notifications
```

### Task 25: Layout Templates System
```
Create built-in zone templates:
1. TemplateLibrary class with predefined templates:
   - 2 Column Split (50/50)
   - 3 Column Split (33/33/33)
   - 2 Row Split (50/50 horizontal)
   - 3 Row Split (33/33/33 horizontal)
   - Focus Left (70/30)
   - Focus Right (30/70)
   - Priority Grid (1 large + 4 small corners)
   - Sidebar Left (20/80)
   - Sidebar Right (80/20)
   - Quadrants (25% each corner)

2. Template metadata:
   - Template name
   - Preview thumbnail
   - Description
   - Zone generation function
   - Category (basic, advanced, specialized)

3. Template application:
   - Scale to current display resolution
   - Apply to zone editor canvas
   - Allow immediate customization after applying
   - Remember last used template

4. Custom templates (future):
   - Save current zone configuration as template
   - User template library
   - Export/import templates
```

## Polish & Error Handling

### Task 26: Error Handling & Logging
```
Implement comprehensive error handling:
1. ErrorManager class for:
   - Centralized error logging
   - User-friendly error messages
   - Error categorization (warning, error, critical)
   - Error recovery suggestions

2. Logging system:
   - Write to log file: ~/Library/Logs/FancyAreas/
   - Log levels: debug, info, warning, error
   - Timestamp all entries
   - Include context (current layout, operation, etc.)
   - Rotate logs (keep last 7 days)

3. User notifications:
   - macOS notification center for important errors
   - In-app alerts for critical errors
   - Status messages in UI for minor issues
   - Error details available on click

4. Common error scenarios:
   - Permission denied → guide to system preferences
   - App not found → suggest reinstall or remove from layout
   - File corruption → offer to restore from backup
   - iCloud sync failure → offer retry or disable sync
   - Layout limit reached → prompt to delete old layout
   - Window can't be resized → log and continue
```

### Task 27: Notifications & User Feedback
```
Implement user feedback system:
1. NotificationManager class for:
   - macOS notification center integration
   - In-app transient notifications (toast/banner)
   - Progress indicators
   - Success/error feedback

2. Notification types:
   - Layout applied: "Layout 'Work' activated"
   - Apps restored: "3 of 5 applications restored"
   - Error occurred: "Unable to launch Photoshop"
   - Sync status: "Layouts synced to iCloud"
   - Permission needed: "Accessibility permission required"

3. Progress indicators:
   - Indeterminate progress (syncing, loading)
   - Determinate progress (app restoration X of Y)
   - Cancelable operations
   - Completion states

4. Visual feedback:
   - Menu bar icon state changes
   - Zone overlay highlights
   - Button state changes (hover, active, disabled)
   - Smooth transitions and animations
```

### Task 28: Performance Optimization
```
Optimize app performance:
1. Profiling and benchmarks:
   - Menu bar menu open time: <100ms
   - Zone overlay display: <100ms
   - Layout switching: <500ms
   - App restoration: 2-5 seconds (for 5 apps)
   - Memory usage: <50MB idle, <100MB active

2. Optimizations:
   - Cache zone calculations
   - Lazy load layout previews
   - Debounce frequent operations
   - Use background threads for file I/O
   - Minimize Accessibility API calls
   - Optimize zone overlay rendering
   - Efficient event monitoring

3. Memory management:
   - Release unused resources
   - Clean up temporary files
   - Limit cache sizes
   - Monitor memory pressure

4. Startup optimization:
   - Fast launch (< 1 second)
   - Defer non-critical initialization
   - Load last active layout quickly
   - Background tasks after UI ready
```

### Task 29: Accessibility Features
```
Implement accessibility support:
1. VoiceOver support:
   - All UI elements properly labeled
   - Accessibility hints for complex controls
   - Keyboard navigation for all functions
   - Screen reader announcements for state changes

2. Keyboard navigation:
   - Tab order logical and complete
   - All buttons/controls keyboard accessible
   - Shortcuts for common actions
   - Focus indicators visible

3. Accessibility preferences:
   - Respect "Reduce Motion" (disable animations)
   - Respect "Increase Contrast" (adjust colors)
   - Respect "Reduce Transparency" (solid overlays)
   - Large text support where applicable

4. Alternative interaction methods:
   - Keyboard-only zone editing
   - Keyboard-only layout management
   - Keyboard shortcuts for all major functions
   - Alternative to mouse-based snapping (keyboard commands)

5. Zone numbers:
   - Always visible option (for low vision users)
   - High contrast mode
   - Larger text option
```

### Task 30: Testing & Quality Assurance
```
Create comprehensive test suite:
1. Unit tests for:
   - Data models (encoding/decoding)
   - File management (save/load/delete)
   - Zone calculations
   - Monitor configuration comparison
   - Keyboard shortcut handling

2. Integration tests for:
   - Layout activation flow
   - App restoration process
   - Zone snapping behavior
   - Multi-monitor handling
   - iCloud sync operations

3. UI tests for:
   - Menu bar interactions
   - Layout management window
   - Zone editor workflows
   - Preferences changes
   - Error dialog handling

4. Manual testing checklist:
   - Test on Intel and Apple Silicon Macs
   - Test on different macOS versions (11.0+)
   - Test with various monitor configurations
   - Test with common apps (Safari, Finder, etc.)
   - Test permission request flows
   - Test with iCloud enabled/disabled
   - Test 10 layout limit enforcement
   - Test all keyboard shortcuts
   - Test with VoiceOver enabled
   - Test with Reduce Motion enabled

5. Edge cases:
   - Very large displays (5K, 6K)
   - Very small displays
   - Different aspect ratios
   - Display rotation
   - Apps with minimum window sizes
   - Apps that resist resizing
   - Corrupted layout files
   - Full disk scenarios
   - Network interruptions (iCloud sync)
```

## Documentation & Deployment

### Task 31: User Documentation
```
Create user-facing documentation:
1. In-app help:
   - First-run tutorial overlay
   - Contextual help tooltips
   - "?" buttons linking to help sections
   - Welcome screen with quick start guide

2. README.md with:
   - App overview and features
   - Installation instructions
   - System requirements
   - Permission setup guide
   - Quick start guide
   - Troubleshooting section

3. User guide covering:
   - Creating zone layouts
   - Using zone snapping
   - Managing layouts
   - Setting up zones + apps
   - Multi-monitor configurations
   - Keyboard shortcuts reference
   - Preferences explanation
   - iCloud sync setup

4. Video tutorials (optional):
   - Quick start (3 min)
   - Creating your first layout
   - Advanced zone editing
   - Multi-monitor setup
```

### Task 32: Code Documentation
```
Add comprehensive code documentation:
1. Inline documentation:
   - Header comments for all classes
   - Method/function documentation with parameters and return values
   - Complex algorithm explanations
   - TODO/FIXME comments for future improvements

2. Architecture documentation:
   - High-level system design
   - Class diagrams
   - Data flow diagrams
   - State management explanation
   - File format specification

3. API documentation:
   - Public interfaces documented
   - Usage examples
   - Best practices
   - Extension points for future development

4. Developer setup guide:
   - Build instructions
   - Development environment setup
   - Debugging tips
   - Testing procedures