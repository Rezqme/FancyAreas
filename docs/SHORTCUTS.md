# FancyAreas Keyboard Shortcuts

Complete reference for all keyboard shortcuts in FancyAreas.

## Table of Contents

1. [Layout Switching](#layout-switching)
2. [Window Management](#window-management)
3. [Application Control](#application-control)
4. [Navigation](#navigation)
5. [Customizing Shortcuts](#customizing-shortcuts)

## Layout Switching

Quick access to your saved layouts.

| Shortcut | Action | Notes |
|----------|--------|-------|
| **Cmd+Opt+1** | Activate Layout 1 | First layout in your list |
| **Cmd+Opt+2** | Activate Layout 2 | Second layout in your list |
| **Cmd+Opt+3** | Activate Layout 3 | Third layout in your list |
| **Cmd+Opt+4** | Activate Layout 4 | Fourth layout in your list |
| **Cmd+Opt+5** | Activate Layout 5 | Fifth layout in your list |
| **Cmd+Opt+6** | Activate Layout 6 | Sixth layout in your list |
| **Cmd+Opt+7** | Activate Layout 7 | Seventh layout in your list |
| **Cmd+Opt+8** | Activate Layout 8 | Eighth layout in your list |
| **Cmd+Opt+9** | Activate Layout 9 | Ninth layout in your list |
| **Cmd+Opt+0** | Activate Layout 10 | Tenth layout in your list |

**How it works**:
- Layout 1 is the first layout alphabetically in your list
- Layout 10 is the tenth layout (if you have that many)
- Empty slots (e.g., if you only have 5 layouts) do nothing

**Tips**:
- Rename layouts with numbers for easy reference: "1-Coding", "2-Design"
- Use your most common layouts in positions 1-3 for quick access
- Build muscle memory for your top 3 layouts

## Window Management

### Zone Snapping

| Shortcut | Action | Notes |
|----------|--------|-------|
| **Cmd** (hold while dragging) | Show zone overlay | Default modifier key |
| **Opt** (hold while dragging) | Show zone overlay | If configured in Preferences |
| **Ctrl** (hold while dragging) | Show zone overlay | If configured in Preferences |
| **Shift** (hold while dragging) | Show zone overlay | If configured in Preferences |

**Configuring the modifier key**:
1. Open Preferences → General
2. Select "Modifier Key" dropdown
3. Choose your preferred key
4. Change takes effect immediately

**Best practices**:
- **Command (⌘)**: Recommended for right-handed users (easy to hold with left hand while dragging with right)
- **Option (⌥)**: Good alternative if Command conflicts with other apps
- **Control**: Good for left-handed users
- **Shift**: Least recommended (commonly used in other contexts)

### Zone Selection (Coming Soon)

These shortcuts are planned for a future release:

| Shortcut | Action | Notes |
|----------|--------|-------|
| **Cmd+1-9** | Snap frontmost window to zone 1-9 | No dragging required |
| **Cmd+Opt+Arrow Keys** | Snap window to adjacent zone | Quick repositioning |

## Application Control

Main application windows and features.

| Shortcut | Action | Notes |
|----------|--------|-------|
| **Cmd+Opt+Shift+L** | Open Layout Management window | Main layout editor |
| **Cmd+,** (Cmd+Comma) | Open Preferences window | Standard macOS shortcut |
| **Cmd+Q** | Quit FancyAreas | Standard macOS shortcut |

**Layout Management Window shortcuts**:
- **Tab**: Move between panels
- **Arrow Keys**: Navigate layout list
- **Enter**: Activate selected layout
- **Delete**: Delete selected layout
- **Cmd+N**: Create new layout
- **Cmd+D**: Duplicate selected layout
- **Escape**: Close window

## Navigation

### Within Layout Management Window

| Shortcut | Action | Context |
|----------|--------|---------|
| **Tab** | Next field/control | All panels |
| **Shift+Tab** | Previous field/control | All panels |
| **↑ / ↓** | Navigate list | Layout list |
| **Enter** | Activate layout | Layout selected |
| **Space** | Toggle selection | Checkboxes |
| **Delete** | Delete layout | Layout selected |
| **Cmd+N** | New layout | Anytime |
| **Cmd+D** | Duplicate layout | Layout selected |
| **Cmd+E** | Edit layout | Layout selected |
| **Cmd+S** | Save changes | Editing layout |
| **Escape** | Cancel / Close | Anytime |

### Within Preferences Window

| Shortcut | Action | Context |
|----------|--------|---------|
| **Tab** | Next setting | All tabs |
| **Shift+Tab** | Previous setting | All tabs |
| **Space** | Toggle checkbox | Checkboxes |
| **Enter** | Apply / OK | Buttons |
| **Escape** | Close window | Anytime |
| **Cmd+Tab** | Switch between tabs | Use arrow keys after |

### Menu Bar

| Shortcut | Action | Notes |
|----------|--------|-------|
| **Cmd+Click** (menu bar icon) | Open Preferences | Alternative to Cmd+, |
| **Opt+Click** (menu bar icon) | Show debug info | Developer feature |

## Customizing Shortcuts

### How to Customize

1. Open **Preferences → Keyboard Shortcuts**
2. Click on the shortcut you want to change
3. Press your desired key combination
4. Click away or press Enter to save

**Rules**:
- Must include at least one modifier key (Cmd, Opt, Ctrl, Shift)
- Cannot conflict with system shortcuts
- Cannot use F-keys reserved by system (F1-F12 have defaults)

### Resetting Shortcuts

To restore default shortcuts:
1. Open **Preferences → Keyboard Shortcuts**
2. Click **"Reset to Defaults"** button at bottom
3. Confirm the reset

All shortcuts return to factory settings.

### Disabling Shortcuts

To disable a shortcut:
1. Open **Preferences → Keyboard Shortcuts**
2. Click on the shortcut
3. Press **Delete** or **Backspace**
4. Shortcut is now empty (disabled)

## System Shortcuts to Avoid

Be careful not to conflict with these common macOS shortcuts:

### System-Wide
- **Cmd+Tab**: Switch applications
- **Cmd+Space**: Spotlight
- **Cmd+Q**: Quit application
- **Cmd+W**: Close window
- **Cmd+M**: Minimize window
- **Cmd+H**: Hide application
- **Cmd+,**: Preferences (used by FancyAreas)

### Window Management (Mission Control)
- **Ctrl+↑**: Mission Control
- **Ctrl+↓**: Application windows
- **Ctrl+←/→**: Switch spaces
- **F3**: Mission Control (on some Macs)

### Display
- **Cmd+F1**: Mirror displays toggle (on some Macs)
- **Brightness keys**: F1, F2
- **Mission Control key**: F3 or fn+F3

### Accessibility
- **Cmd+Opt+F5**: Accessibility options
- **Cmd+Opt+F8**: VoiceOver

**Tip**: Check System Preferences → Keyboard → Shortcuts to see all system shortcuts before customizing FancyAreas shortcuts.

## Modifier Key Symbols

Understanding macOS keyboard symbols:

| Symbol | Key Name | Notes |
|--------|----------|-------|
| **⌘** | Command | Primary modifier on Mac |
| **⌥** | Option (Alt) | Secondary modifier |
| **⌃** | Control | Used less frequently |
| **⇧** | Shift | Capitalization and secondary functions |
| **⇪** | Caps Lock | Rarely used in shortcuts |
| **↑ ↓ ← →** | Arrow Keys | Navigation |
| **⏎** | Return (Enter) | Confirm actions |
| **⎋** | Escape | Cancel actions |
| **⌫** | Delete | Remove/delete |
| **⌦** | Forward Delete | Delete forward (fn+Delete on some keyboards) |

## Quick Reference Card

Print this section for easy access:

```
┌─────────────────────────────────────────────────────┐
│         FANCYAREAS KEYBOARD SHORTCUTS               │
├─────────────────────────────────────────────────────┤
│                                                     │
│  LAYOUTS                                            │
│  Cmd+Opt+1-0     Switch to layout 1-10              │
│  Cmd+Opt+Shift+L Layout Management                  │
│                                                     │
│  SNAPPING                                           │
│  Cmd (hold)      Show zone overlay                  │
│                                                     │
│  APPLICATION                                        │
│  Cmd+,           Preferences                        │
│  Cmd+Q           Quit FancyAreas                    │
│                                                     │
│  LAYOUT MANAGEMENT                                  │
│  ↑/↓             Navigate layouts                   │
│  Enter           Activate layout                    │
│  Delete          Delete layout                      │
│  Cmd+N           New layout                         │
│  Cmd+D           Duplicate layout                   │
│  Escape          Close window                       │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## Advanced Tips

### Modifier Key Combinations

You can use multiple modifiers for more complex shortcuts:

**Examples**:
- **Cmd+Opt+Shift+L**: Layout Management (default)
- **Cmd+Shift+1**: Custom zone snap (future)
- **Ctrl+Opt+Z**: Toggle zones (future)

**Best practices**:
- 2 modifiers: Good balance of complexity and usability
- 3 modifiers: Very specific, hard to accidentally trigger
- 4 modifiers: Overkill, avoid

### One-Handed Shortcuts

For maximum efficiency, use shortcuts you can press with one hand:

**Left hand only** (for right-handed mouse users):
- **Cmd+1-5**: Easy to reach with left hand
- **Cmd+Tab**: Switch apps while mousing
- **Cmd+Space**: Spotlight while mousing

**Right hand only** (for left-handed mouse users):
- **Cmd+Opt+8-0**: Right side of keyboard
- Numpad shortcuts (if keyboard has numpad)

### Workflow-Specific Shortcuts

Create shortcut patterns for different workflows:

**Development**:
- **Cmd+Opt+1**: Code editor layout
- **Cmd+Opt+2**: Debug layout
- **Cmd+Opt+3**: Testing layout

**Design**:
- **Cmd+Opt+1**: Design tool focus
- **Cmd+Opt+2**: Asset management
- **Cmd+Opt+3**: Client presentation

**Writing**:
- **Cmd+Opt+1**: Distraction-free writing
- **Cmd+Opt+2**: Research + writing
- **Cmd+Opt+3**: Editing mode

## Accessibility

### VoiceOver Shortcuts

When VoiceOver is enabled:

| Shortcut | Action | Notes |
|----------|--------|-------|
| **VO+Space** | Activate control | VO = Ctrl+Opt by default |
| **VO+Arrow Keys** | Navigate interface | Move VoiceOver cursor |
| **VO+Cmd+H** | Go to home row | Quick navigation |

FancyAreas is fully compatible with VoiceOver. All actions can be performed with keyboard + VoiceOver.

### Keyboard-Only Operation

FancyAreas can be used entirely without a mouse:

1. **Launch**: Cmd+Space → type "FancyAreas" → Enter
2. **Open Layout Management**: Cmd+Opt+Shift+L
3. **Navigate layouts**: Arrow keys
4. **Activate layout**: Enter
5. **Switch layouts**: Cmd+Opt+1-0
6. **Open Preferences**: Cmd+,
7. **Navigate preferences**: Tab, Shift+Tab
8. **Quit**: Cmd+Q

No mouse required!

### Reduce Motion

If you have **Reduce Motion** enabled in macOS:
- FancyAreas respects this setting
- Animations are disabled
- Shortcuts still work normally
- Instant snapping instead of animated

## Troubleshooting Shortcuts

### Shortcut Not Working

**Check these**:
1. Is the shortcut enabled in Preferences → Keyboard Shortcuts?
2. Does it conflict with another app's shortcut?
3. Is FancyAreas running? (Check menu bar)
4. Do you have the correct modifier keys?

**Test**:
- Try the shortcut in a different app
- Check System Preferences → Keyboard → Shortcuts for conflicts

### Modifier Key Not Showing Overlay

**Solutions**:
1. Verify Screen Recording permission is granted
2. Check Preferences → General → Modifier Key setting
3. Ensure an active layout exists
4. Restart FancyAreas

### Keyboard Shortcuts Not Customizing

**Possible issues**:
- Conflicting with system shortcut (macOS blocks it)
- Missing modifier key (must include Cmd, Opt, Ctrl, or Shift)
- Reserved shortcut (some shortcuts are protected by macOS)

**Try**:
- Add more modifiers to avoid conflicts
- Choose different base key
- Check Console.app for errors

---

**Need more help?** See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) or visit [GitHub Discussions](https://github.com/your-org/FancyAreas/discussions).

**Last Updated**: 2025-01-24
