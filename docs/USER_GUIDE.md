# FancyAreas User Guide

Complete guide to using FancyAreas for window management on macOS.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Creating Layouts](#creating-layouts)
3. [Managing Layouts](#managing-layouts)
4. [Using Zone Overlays](#using-zone-overlays)
5. [Window Snapping](#window-snapping)
6. [App Restoration](#app-restoration)
7. [Keyboard Shortcuts](#keyboard-shortcuts)
8. [Preferences](#preferences)
9. [Multi-Monitor Setup](#multi-monitor-setup)
10. [Tips & Tricks](#tips--tricks)
11. [FAQ](#faq)

## Getting Started

### First Launch Setup

When you launch FancyAreas for the first time, you'll be guided through a setup wizard:

#### Step 1: Accessibility Permission

FancyAreas needs Accessibility permission to control window positions.

1. Click **"Open System Preferences"**
2. Navigate to **Security & Privacy → Privacy → Accessibility**
3. Click the lock icon to make changes
4. Check the box next to **FancyAreas**
5. Close System Preferences

#### Step 2: Screen Recording Permission

FancyAreas needs Screen Recording permission to detect when you're dragging windows.

**Note**: FancyAreas does NOT actually record your screen. This permission is required by macOS to monitor global mouse events.

1. Click **"Open System Preferences"**
2. Navigate to **Security & Privacy → Privacy → Screen Recording**
3. Check the box next to **FancyAreas**
4. Quit and relaunch FancyAreas

#### Step 3: Launch on Login (Optional)

Choose whether FancyAreas should start automatically when you log in.

- **Enable**: FancyAreas will start in the background at login
- **Skip**: You can enable this later in Preferences → Advanced

### Understanding the Menu Bar

After setup, you'll see the FancyAreas icon in your menu bar. Click it to access:

- **Layout List**: All your saved layouts (click to activate)
- **Manage Layouts...**: Open the Layout Management window
- **Preferences...**: Configure FancyAreas settings
- **About FancyAreas**: Version and credits
- **Quit FancyAreas**: Exit the application

## Creating Layouts

### Using Templates

Templates are the fastest way to create layouts. FancyAreas includes 10 built-in templates:

#### Opening the Template Library

1. Click menu bar icon → **"Manage Layouts..."**
2. Click the **"+"** button to create a new layout
3. The Template Library appears in the right panel

#### Available Templates

**Basic Templates**

- **2 Column Split**: Two equal vertical columns (50/50)
  ```
  ┌──────┬──────┐
  │  1   │  2   │
  │      │      │
  │      │      │
  └──────┴──────┘
  ```

- **3 Column Split**: Three equal columns (33/33/33)
  ```
  ┌────┬────┬────┐
  │ 1  │ 2  │ 3  │
  │    │    │    │
  │    │    │    │
  └────┴────┴────┘
  ```

- **2 Row Split**: Two horizontal rows (50/50)
  ```
  ┌──────────────┐
  │      1       │
  ├──────────────┤
  │      2       │
  └──────────────┘
  ```

**Grid Templates**

- **Grid 2x2**: Four equal quadrants
  ```
  ┌──────┬──────┐
  │  1   │  2   │
  ├──────┼──────┤
  │  3   │  4   │
  └──────┴──────┘
  ```

- **Grid 3x3**: Nine equal zones
  ```
  ┌────┬────┬────┐
  │ 1  │ 2  │ 3  │
  ├────┼────┼────┤
  │ 4  │ 5  │ 6  │
  ├────┼────┼────┤
  │ 7  │ 8  │ 9  │
  └────┴────┴────┘
  ```

**Focus Templates**

- **Left Focus**: Large left zone (66%) + small right zone (33%)
  ```
  ┌──────────┬────┐
  │          │  2 │
  │    1     │    │
  │          │    │
  └──────────┴────┘
  ```

- **Right Focus**: Small left zone (33%) + large right zone (66%)
  ```
  ┌────┬──────────┐
  │  1 │          │
  │    │    2     │
  │    │          │
  └────┴──────────┘
  ```

- **Center Focus**: Centered zone (70%) with side zones
  ```
  ┌──┬──────────┬──┐
  │1 │          │ 3│
  │  │    2     │  │
  │  │          │  │
  └──┴──────────┴──┘
  ```

**Specialized Templates**

- **Ultrawide 3-Zone**: Optimized for ultrawide monitors (21:9, 32:9)
  ```
  ┌────────┬────────┬────────┐
  │   1    │   2    │   3    │
  │        │        │        │
  │        │        │        │
  └────────┴────────┴────────┘
  ```

- **Picture in Picture**: Small floating zone + large background
  ```
  ┌────────────────┐
  │                │
  │       1        │
  │          ┌────┐│
  │          │ 2  ││
  └──────────┴────┘│
  ```

#### Applying a Template

1. Select a template from the library
2. Preview appears in the center panel
3. Click **"Use Template"**
4. Enter a name for your layout (e.g., "Coding Setup")
5. Click **"Save"**

Your layout is now saved and ready to use!

### Creating Custom Layouts

For complete control, create a custom layout from scratch:

#### Manual Zone Creation

1. Open Layout Management window
2. Click **"+"** to create new layout
3. Skip the template selection
4. Click **"Add Zone"** in the zone editor
5. Drag the zone handles to position and size
6. Repeat for additional zones
7. Name and save your layout

#### Setting Zone Properties

Select any zone in the preview to edit:

**Basic Properties**
- **Zone Number**: 1-9 for quick reference
- **Display**: Which monitor the zone is on
- **Position**: X and Y coordinates (in pixels)
- **Size**: Width and height (in pixels)

**Advanced Properties**
- **Assigned App**: Optional app to launch in this zone
- **Padding**: Internal spacing within the zone
- **Snap Behavior**: How windows align to the zone

#### Tips for Custom Layouts

- **Align zones**: Use the grid overlay for precise positioning
- **No gaps**: Zones should touch edges for best snapping experience
- **Zone numbers**: Assign meaningful numbers (e.g., 1 for main workspace)
- **Test on actual display**: Preview shows your real monitor dimensions

### Duplicating Layouts

To create a variant of an existing layout:

1. Right-click the layout in the list
2. Select **"Duplicate"**
3. Modify the duplicate as needed
4. Rename and save

This is useful for creating similar layouts for different monitor configurations.

## Managing Layouts

### Layout Management Window

Access via menu bar icon → **"Manage Layouts..."** or press **Cmd+Opt+Shift+L**.

The window has three panels:

#### Left Panel: Layout List

Shows all saved layouts with:
- Layout name
- Layout type icon (Zones only / Zones + Apps)
- Monitor configuration
- Last modified date

**Actions**:
- Click to select
- Double-click to activate
- Right-click for context menu

#### Center Panel: Zone Preview

Visual preview showing:
- All zones with their positions
- Zone numbers
- Zone boundaries
- Display dimensions

**Features**:
- Zoom in/out for detail
- Pan to view specific areas
- Toggle zone numbers on/off

#### Right Panel: Properties

Shows details about selected layout or zone:

**Layout Properties**:
- Name
- Type
- Created date
- Modified date
- Monitor configuration
- Tags (optional)

**Zone Properties**:
- Zone number
- Bounds (X, Y, Width, Height)
- Assigned app (optional)

### Activating Layouts

Several ways to activate a layout:

**Method 1: Menu Bar**
1. Click FancyAreas menu bar icon
2. Select layout from the menu

**Method 2: Layout Management Window**
1. Select layout in the list
2. Click **"Activate"** button

**Method 3: Keyboard Shortcut**
- Press **Cmd+Opt+1** through **Cmd+Opt+0** for layouts 1-10

**Method 4: Layout Picker**
- Press **Cmd+Opt+Shift+L**
- Select layout from the list
- Press Enter

### Editing Layouts

To modify an existing layout:

1. Open Layout Management window
2. Select the layout
3. Click **"Edit"** button
4. Make your changes in the zone editor
5. Click **"Save"** to apply changes

**Note**: If a layout is currently active, changes take effect immediately.

### Deleting Layouts

To remove a layout:

**Method 1**:
1. Select layout in Layout Management
2. Press **Delete** key
3. Confirm deletion

**Method 2**:
1. Right-click layout
2. Select **"Delete"**
3. Confirm deletion

**Warning**: Deletion is permanent and cannot be undone.

### Exporting and Importing Layouts

Share layouts with others or back them up:

#### Exporting

1. Right-click a layout
2. Select **"Export Layout..."**
3. Choose save location
4. File is saved as `.fancyareas` format

#### Importing

1. Click **"Import"** button in Layout Management
2. Select a `.fancyareas` file
3. Layout is added to your list

**Note**: Imported layouts may need adjustment if your monitor configuration differs.

### Layout Limit

FancyAreas enforces a limit of **10 layouts per machine** to keep things manageable.

**When limit is reached**:
- Delete unused layouts to make room
- Export layouts you want to keep but don't use regularly
- Import layouts only when needed

**Why 10 layouts?**
- Keeps menu bar clean
- Keyboard shortcuts limited to Cmd+Opt+1-0
- Encourages focused, well-designed layouts

## Using Zone Overlays

### How Overlays Work

Zone overlays are transparent windows that appear on top of everything when you're dragging a window with the modifier key held.

**Overlay Features**:
- Semi-transparent colored rectangles for each zone
- Zone numbers in the top-left corner
- Green highlighting for the zone under your cursor
- Smooth fade in/out animations

### Showing the Overlay

The overlay appears automatically when:
1. You start dragging any window
2. You hold the configured modifier key (default: Command ⌘)
3. An active layout exists

### Hiding the Overlay

The overlay disappears when:
- You release the modifier key
- You release the mouse button (snap complete)
- You press Escape

### Overlay Customization

In Preferences → Appearance:

**Opacity**
- Adjust transparency from 10% to 100%
- Higher opacity = more visible zones
- Lower opacity = less screen obstruction
- Default: 30%

**Zone Numbers**
- Toggle zone number display on/off
- Numbers appear in top-left corner of each zone
- Helpful for learning keyboard shortcuts
- Default: On

**Border Width**
- Adjust thickness of zone borders (1-5px)
- Thicker borders = easier to see boundaries
- Thinner borders = less intrusive
- Default: 2px

**Colors** (coming soon)
- Customize zone color
- Customize highlight color
- Choose opacity levels

### Multi-Monitor Overlays

With multiple displays:
- Overlays appear on **all monitors** simultaneously
- Each display shows its own zones
- Highlighting works across monitors
- Drag windows between displays seamlessly

## Window Snapping

### Basic Snapping

1. Click and start dragging any window's title bar
2. Hold the modifier key (default: **Command ⌘**)
3. Zone overlay appears
4. Drag window over a zone
5. Zone highlights in green
6. Release mouse button
7. Window snaps to the zone with smooth animation

### Snapping to Specific Zones

**Visual Selection**:
- Drag cursor over the desired zone
- Zone highlights green to confirm
- Release to snap

**Keyboard Selection** (coming soon):
- Hold modifier key
- Press zone number (1-9)
- Window snaps without dragging

### Snap Animations

**Default Behavior**:
- Smooth 60fps animation
- Duration: 0.25 seconds
- Easing: ease-in-out quad

**Customization**:
In Preferences → General:
- Adjust animation duration (0.1s - 1.0s)
- Disable animations entirely
- Respect system Reduce Motion setting

**Performance**:
- Animations run on background thread
- No UI blocking or lag
- Respects window size constraints

### Window Constraints

FancyAreas respects app-imposed window size limits:

**Minimum Size**:
- If zone is smaller than app's minimum size
- Window snaps to minimum size
- Positioned at zone's top-left

**Maximum Size**:
- If zone is larger than app's maximum size
- Window snaps to maximum size
- Centered within the zone

**Fixed Aspect Ratio**:
- Some apps maintain aspect ratio
- Window fills zone as much as possible
- Maintains aspect ratio

**Examples**:
- Terminal: Minimum size based on font/columns
- Preview: Aspect ratio of current image
- Safari: No significant constraints

### Unsupported Windows

Some windows cannot be snapped:

**Full-Screen Windows**:
- Exit full-screen mode first
- Use green button or Ctrl+Cmd+F

**Split View Windows**:
- Exit Split View first
- Hover over green button → Exit Split View

**System Dialogs**:
- Open/Save dialogs
- System alerts
- Cannot be resized

**Protected Apps**:
- Some security apps resist control
- Check app's accessibility settings

### Snap Spacing

Configure gaps between windows:

**Edge Spacing**:
- Gap between windows and screen edges
- Adjustable 0-20 pixels
- Default: 0 pixels

**Zone Spacing**:
- Gap between adjacent zone windows
- Adjustable 0-20 pixels
- Default: 0 pixels

**Use Cases**:
- No spacing (0px): Maximum screen usage
- Small spacing (5px): Visual separation
- Large spacing (10-20px): Desktop widgets visible

## App Restoration

### What is App Restoration?

App restoration automatically launches and positions apps in their assigned zones. Perfect for:
- Starting your workday with apps in place
- Switching between task-specific setups
- Recovering from restarts or crashes

### Assigning Apps to Zones

#### Method 1: During Layout Creation

1. Create or edit a layout
2. Select a zone in the preview
3. Click **"Assign App"** in the properties panel
4. Choose an app from the dropdown
5. Optionally specify a window title filter
6. Save the layout

#### Method 2: From Running Apps

1. Position apps manually in zones
2. Right-click zone in Layout Management
3. Select **"Assign Current Window"**
4. App is automatically assigned

### Restoring Apps

**Automatic Restoration**:
- Enable "Auto-restore last layout" in Preferences
- Apps restore when FancyAreas launches
- Progress shown in notification

**Manual Restoration**:
1. Click menu bar icon
2. Select a layout
3. Choose **"Restore Apps"** from submenu
4. Wait for progress notification

### Restoration Behavior

**Non-Destructive**:
- Does NOT close existing windows
- Only launches/positions assigned apps
- Additive approach

**For Running Apps**:
- Finds app's frontmost window
- Moves to assigned zone
- Fast and immediate

**For Non-Running Apps**:
- Launches app in background
- Waits for app to initialize
- Positions window when ready
- Timeout: 5 seconds

**Error Handling**:
- App not found: Shows notification
- App fails to launch: Shows error
- App unresponsive: Times out gracefully
- Continues with remaining apps

### Window Title Matching

For apps with multiple windows:

**Use Case**: You want Chrome with "Gmail" window in zone 1, "Calendar" in zone 2.

**Setup**:
1. Assign Chrome to zone 1
2. Set window title filter to "Gmail"
3. Assign Chrome to zone 2
4. Set window title filter to "Calendar"

**Matching**:
- FancyAreas searches for matching title
- Uses partial matching (contains)
- Case-insensitive
- Falls back to any window if no match

### Progress Notifications

During restoration, you'll see:
- **Start**: "Restoring apps from 'Coding Setup'..."
- **Progress**: "Positioning Safari, Chrome, VS Code..."
- **Complete**: "Restored 8 of 10 apps successfully"
- **Errors**: "Failed to launch Xcode (not found)"

## Keyboard Shortcuts

See [SHORTCUTS.md](SHORTCUTS.md) for complete reference.

### Essential Shortcuts

- **Cmd+Opt+1** - **Cmd+Opt+0**: Switch to layout 1-10
- **Cmd+Opt+Shift+L**: Open Layout Management window
- **Cmd+,**: Open Preferences
- **Command (hold while dragging)**: Show zone overlay

## Preferences

Access via menu bar icon → **"Preferences..."** or press **Cmd+,**.

### General Tab

#### Zone Snapping Behavior

**Modifier Key**:
- Choose which key triggers zone overlay
- Options: Command, Option, Control, Shift
- Default: Command ⌘
- Changes apply immediately

**Animation Duration**:
- Adjust snap animation speed
- Range: 0.1s (fast) to 1.0s (slow)
- Default: 0.25s
- Preview updates in real-time

**Enable Animations**:
- Toggle window animations on/off
- When off: Instant snapping
- Improves performance on older Macs
- Default: On

**Respect Reduce Motion**:
- Honor system accessibility setting
- When enabled: Disables animations if system setting is on
- Found in: System Preferences → Accessibility → Display
- Default: On

#### Zone Spacing

**Edge Spacing**:
- Gap between windows and screen edges
- Range: 0-20 pixels
- Default: 0px
- Visual: Shows example spacing

**Zone Spacing**:
- Gap between adjacent zones
- Range: 0-20 pixels
- Default: 0px
- Creates "breathing room" between windows

#### Layout Management

**Auto-restore last layout**:
- Restore last active layout when FancyAreas launches
- Includes app restoration if enabled
- Useful for consistent startup
- Default: On

**Show warnings for monitor changes**:
- Alert when monitor configuration changes
- Warns if layout may not fit
- Helpful for laptop + external monitor users
- Default: On

### Appearance Tab

#### Zone Overlay

**Overlay Opacity**:
- Transparency of zone overlays
- Range: 10% to 100%
- Default: 30%
- Live preview as you adjust

**Show Zone Numbers**:
- Display zone numbers on overlay
- Numbers appear in top-left corner
- Helpful for learning layouts
- Default: On

**Zone Color**:
- Color of inactive zones
- Default: System blue
- Coming soon: Custom colors

**Active Zone Color**:
- Color of highlighted zone (under cursor)
- Default: System green
- Coming soon: Custom colors

**Border Width**:
- Thickness of zone borders
- Range: 1-5 pixels
- Default: 2px
- Thicker = more visible

#### Menu Bar

**Show icon in menu bar**:
- Toggle FancyAreas menu bar icon
- When off: Access via Cmd+Opt+Shift+L
- Default: On

**Show active layout name**:
- Display current layout name in menu
- Helpful for remembering which layout is active
- Default: Off (to save menu bar space)

### Advanced Tab

#### Performance

**Zone Detection Algorithm**:
- Spatial Grid (recommended): O(1) average case, <1ms
- Linear Search: O(n), simpler but slower
- Default: Spatial Grid

**Overlay Refresh Rate**:
- Fixed at 60fps for smooth animations
- Cannot be changed

#### Startup

**Launch on Login**:
- Start FancyAreas automatically at login
- Launches hidden in background
- Uses modern SMAppService API
- Default: Off (set during first-run wizard)

**Start Minimized**:
- Hide main window on launch
- Only show menu bar icon
- Reduces startup clutter
- Default: On

#### Accessibility

**Enable VoiceOver Support**:
- Enhanced screen reader integration
- Announces zone changes
- Describes zones verbally
- Default: On (if VoiceOver is running)

**Keyboard Navigation**:
- Full keyboard control in all windows
- Tab through all controls
- Arrow keys in lists
- Default: On (always)

#### iCloud

**Sync Preferences**:
- Sync settings across all Macs via iCloud
- Requires iCloud enabled in System Preferences
- Syncs: Preferences, keyboard shortcuts
- Does NOT sync: Layout files
- Default: Off

**Sync Layouts** (coming soon):
- Sync layout files via iCloud Drive
- Automatically keep layouts in sync
- Requires iCloud Drive enabled

### Keyboard Shortcuts Tab

**Customize Shortcuts**:
- Click a shortcut to record new key combination
- Press Esc to cancel
- Press Delete/Backspace to clear shortcut

**Available Shortcuts**:
- Layout 1-10 switches
- Open Preferences
- Open Layout Management
- Toggle active layout
- Show/hide overlay

**Reset to Defaults**:
- Restores all shortcuts to factory settings

## Multi-Monitor Setup

### Display Detection

FancyAreas automatically detects:
- All connected displays
- Display resolutions
- Display positions (arrangement)
- Primary display
- Built-in vs external displays

**Real-time Updates**:
- Connects/disconnects detected instantly
- Layouts adjust automatically
- Notifications shown for changes

### Creating Multi-Monitor Layouts

1. Connect all displays you want to include
2. Open Layout Management window
3. Create a new layout
4. In zone editor, select which display each zone is on
5. Position zones on each display
6. Save layout

**Tips**:
- Create separate layouts for different monitor configs
- Name layouts descriptively: "Laptop Only", "Desk Setup", etc.
- Test each layout before saving

### Monitor Configuration Matching

When activating a layout, FancyAreas checks:

**Compatible Match**:
- Same number of displays
- Same display IDs
- Layout activates normally

**Similar Match**:
- Same number of displays
- Different display IDs (display replaced)
- Warning shown, layout activates with confirmation

**Incompatible Match**:
- Different number of displays
- Layout may not work correctly
- Strong warning shown, optional to continue

### Best Practices for Multi-Monitor

**Laptop Users**:
- Create "Laptop Only" layout for travel
- Create "Desk Setup" for home/office
- Enable "Auto-restore last layout" to maintain config

**Desk Setup**:
- Arrange displays logically (left-to-right)
- Set primary display appropriately
- Create zones that span your workflow

**Hot-desking**:
- Export your layouts to take with you
- Import on different workstations
- Adjust for different monitor configs

### Troubleshooting Multi-Monitor

**Zones on wrong display**:
- Display arrangement may have changed
- Re-check display arrangement in System Preferences
- Edit layout to adjust zone display assignments

**Layout doesn't activate**:
- Check monitor configuration warning
- Create new layout for current configuration
- Verify all displays are connected

**Performance issues**:
- Close layouts on unused displays
- Reduce number of zones per display
- Disable animations for better performance

## Tips & Tricks

### Workflow Optimization

**Task-Specific Layouts**:
- Create layouts for different tasks: Coding, Design, Writing, etc.
- Use keyboard shortcuts to switch instantly
- Assign relevant apps to each layout

**The 3-Layout Strategy**:
1. **Focus Layout**: Single large zone for deep work
2. **Collaboration Layout**: Split screen for communication + work
3. **Research Layout**: Multiple zones for browsing + note-taking

**Morning Routine**:
1. Enable "Launch on Login"
2. Set "Auto-restore last layout"
3. Assign your morning apps (email, calendar, chat)
4. Start your day with everything in place

### Advanced Techniques

**Nested Workflows**:
- Use multiple layouts for sub-tasks
- Switch between them as your focus changes
- Example: Coding Layout → Debug Layout → Code Review Layout

**App-Zone Pairing**:
- Dedicate specific zones to specific apps
- Always snap IDE to zone 1
- Always snap browser to zone 2
- Build muscle memory

**Template Customization**:
- Start with a template
- Adjust zone sizes to your preference
- Save as custom layout
- Share with team members

### Performance Tips

**Optimal Zone Count**:
- 2-4 zones: Simple, fast, easy to target
- 5-6 zones: Balanced, covers most needs
- 7-9 zones: Advanced, requires precision
- 10+: Rarely needed, harder to use

**Animation Settings**:
- Disable animations on older Macs
- Use shorter duration (0.1s) for snappier feel
- Enable Reduce Motion for accessibility

**Layout Organization**:
- Delete unused layouts to reduce clutter
- Export layouts you use occasionally
- Keep active layouts under 5 for quick access

### Sharing Layouts

**With Team Members**:
1. Export your layouts
2. Share .fancyareas files via chat/email
3. Team imports and adjusts for their monitors
4. Consistent window placement across team

**Open Source Community**:
- Share creative layouts on GitHub Discussions
- Download community-created templates
- Contribute improvements back

## FAQ

### General Questions

**Q: How is FancyAreas different from Rectangle or Magnet?**

A: FancyAreas focuses on predefined zones with visual overlays, similar to Windows PowerToys FancyZones. Rectangle and Magnet use keyboard shortcuts for predefined positions. FancyAreas is more visual and flexible for complex layouts.

**Q: Can I use FancyAreas alongside other window managers?**

A: Technically yes, but not recommended. Multiple window managers may conflict when trying to control the same windows. Choose one that fits your workflow best.

**Q: Does FancyAreas work on my Mac?**

A: FancyAreas requires macOS 11.0 (Big Sur) or later. It's a Universal Binary that runs natively on both Apple Silicon and Intel Macs.

### Layout Questions

**Q: Why is there a 10-layout limit?**

A: To keep the menu bar clean and keyboard shortcuts manageable (Cmd+Opt+1-0). You can export/import layouts to have unlimited storage, just not all active at once.

**Q: Can I have different layouts for different times of day?**

A: Not automatically yet, but you can manually switch layouts via keyboard shortcuts. Automatic layout switching based on time/context is planned for a future release.

**Q: Can layouts include window opacity or always-on-top settings?**

A: Not currently. FancyAreas focuses on position and size. Window properties like opacity and window level would require deeper system integration.

### Snapping Questions

**Q: Why do some windows not snap?**

A: Some apps restrict window control via the Accessibility API. Full-screen windows and system dialogs also cannot be snapped. Try exiting full-screen mode first.

**Q: Can I snap windows without dragging them?**

A: Not in the current version. Keyboard-only snapping (press zone number without dragging) is planned for a future release.

**Q: Does snapping work with Mission Control or Spaces?**

A: Yes, but zones only apply to the current Space. Each Space maintains its own window positions. If you switch Spaces, you'll need to snap windows again on that Space.

### Performance Questions

**Q: Is FancyAreas resource-intensive?**

A: No. FancyAreas uses <100MB RAM and <5% CPU when idle. During snapping, CPU briefly spikes for animations but remains smooth. Zone detection is optimized to <1ms per lookup.

**Q: Will FancyAreas slow down my Mac?**

A: No measurable impact. The app is highly optimized and runs mostly in the background. You can disable animations for even better performance on older Macs.

### Privacy Questions

**Q: Does FancyAreas collect data about my usage?**

A: No. FancyAreas is 100% local. No analytics, telemetry, or usage data is collected. iCloud sync (if enabled) only uses your private iCloud account.

**Q: What does FancyAreas access with Screen Recording permission?**

A: FancyAreas monitors mouse events to detect window dragging. It does NOT capture screenshots, record video, or access screen content beyond detecting cursor position and modifier keys.

**Q: Can FancyAreas see sensitive information in my windows?**

A: No. FancyAreas uses the Accessibility API to get window positions and sizes, not window content. It cannot read text, capture screenshots, or access data within your apps.

### Troubleshooting Questions

**Q: Why doesn't the overlay appear when I drag windows?**

A: Check these:
1. Is an active layout enabled? (check menu bar)
2. Are you holding the correct modifier key? (default: Command)
3. Is Screen Recording permission granted? (System Preferences → Security & Privacy)
4. Try restarting FancyAreas

**Q: Why do windows snap to the wrong position?**

A: This usually happens after monitor configuration changes. Edit the layout to update zone positions for your current displays.

**Q: FancyAreas stopped working after a macOS update. What do I do?**

A: macOS updates sometimes reset permissions. Re-grant Accessibility and Screen Recording permissions in System Preferences → Security & Privacy.

---

**Still have questions?**

- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- Visit [GitHub Discussions](https://github.com/your-org/FancyAreas/discussions)
- Open an issue on [GitHub Issues](https://github.com/your-org/FancyAreas/issues)
