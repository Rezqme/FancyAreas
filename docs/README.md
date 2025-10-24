# FancyAreas

A powerful macOS window management tool that lets you snap windows into predefined zones using drag-and-drop with modifier keys.

## Features

### Core Capabilities
- **Zone-Based Window Snapping**: Define custom zones and snap windows by dragging with modifier keys
- **Multi-Monitor Support**: Full support for multiple displays with independent zone layouts
- **Visual Zone Overlay**: See your zones highlighted when dragging windows
- **Smooth Animations**: Buttery-smooth 60fps window animations (respects Reduce Motion)
- **Template Library**: 10 built-in zone templates (2-column, 3-column, grid layouts, ultrawide, etc.)
- **Keyboard Shortcuts**: Quick layout switching with Cmd+Opt+1-0
- **App Restoration**: Save app positions and restore them automatically

### Advanced Features
- **iCloud Sync**: Sync your preferences across all your Macs
- **Custom Layouts**: Create up to 10 custom layouts per machine
- **Layout Switching**: Quickly switch between different zone configurations
- **Monitor Detection**: Automatically detects display changes and adjusts layouts
- **Performance Optimized**: Sub-millisecond zone detection with spatial grid algorithm
- **Accessibility Support**: Full VoiceOver support and keyboard navigation

## System Requirements

- macOS 11.0 (Big Sur) or later
- Apple Silicon or Intel Mac
- Accessibility permissions required
- Screen Recording permissions required (for window drag detection)

## Installation

### Manual Installation

1. Download the latest release from the [Releases](https://github.com/your-org/FancyAreas/releases) page
2. Unzip the downloaded file
3. Drag **FancyAreas.app** to your Applications folder
4. Launch FancyAreas from your Applications folder

### Building from Source

```bash
git clone https://github.com/your-org/FancyAreas.git
cd FancyAreas/FancyAreas
swift build -c release
# Or open Package.swift in Xcode
```

### First Launch

When you first launch FancyAreas, you'll see a setup wizard that guides you through:

1. **Accessibility Permission**: Required to control window positions
   - Click "Open System Preferences"
   - Enable FancyAreas in the Accessibility list

2. **Screen Recording Permission**: Required to detect window dragging
   - Click "Open System Preferences"
   - Enable FancyAreas in the Screen Recording list

3. **Launch on Login**: Optionally set FancyAreas to start automatically

After granting permissions, you may need to restart the app.

## Quick Start Guide

### 1. Create Your First Layout

1. Click the FancyAreas menu bar icon
2. Select **"Manage Layouts..."**
3. Click the **"+"** button to create a new layout
4. Choose a template from the Template Library (or create custom zones)
5. Name your layout (e.g., "Coding Setup")
6. Click **"Save"**

### 2. Activate a Layout

1. Click the FancyAreas menu bar icon
2. Select your layout from the menu
3. The layout is now active and ready to use

### 3. Snap Windows to Zones

1. Start dragging any window
2. Hold the modifier key (default: **Command ⌘**)
3. The zone overlay appears showing available zones
4. Drag the window over a zone (it highlights green)
5. Release the mouse button to snap the window

That's it! Your window is now perfectly positioned in the zone.

## Documentation

For comprehensive documentation, see:

- **[User Guide](docs/USER_GUIDE.md)**: Detailed feature documentation
- **[Architecture Guide](docs/ARCHITECTURE.md)**: Developer documentation
- **[Troubleshooting](docs/TROUBLESHOOTING.md)**: Common issues and solutions
- **[Keyboard Shortcuts](docs/SHORTCUTS.md)**: Complete shortcut reference

## Keyboard Shortcuts

### Layout Switching
- **Cmd+Opt+1** through **Cmd+Opt+0**: Switch to layout 1-10
- **Cmd+Opt+Shift+L**: Open Layout Management window

### Application
- **Cmd+,** (Cmd+Comma): Open Preferences

### Window Snapping
- **Cmd** (default): Show zone overlay while dragging (configurable)

## Project Structure

```
FancyAreas/
├── FancyAreas/              # Main application code
│   ├── Models/              # Data models (Layout, Zone, Display, etc.)
│   ├── Controllers/         # Business logic controllers
│   ├── Views/               # SwiftUI/AppKit views
│   ├── Utilities/           # Helper classes
│   └── Resources/           # Assets and Info.plist
├── FancyAreasTests/         # Unit, integration, and performance tests
├── docs/                    # Documentation
├── Package.swift            # Swift Package Manager config
└── README.md               # This file
```

## Development Status

**Current Status**: Core implementation complete (Tasks 1-30 of 32)

### ✅ Completed Features
- Core data models with Codable support
- File management system (.fancyareas format)
- Permission management with first-run wizard
- Menu bar integration
- Launch on login functionality
- Zone detection with spatial grid optimization (<1ms)
- Window drag event monitoring with CGEventTap
- Zone overlay display system
- Window snapping engine with smooth animations
- Preferences window with iCloud sync
- Layout management UI (three-panel design)
- Template library with 10 built-in templates
- Multi-monitor support with display detection
- App restoration system
- Keyboard shortcuts system
- Error handling and logging
- User notifications with toast UI
- Performance optimization
- Accessibility support (VoiceOver, keyboard navigation)
- Comprehensive test suite

### 📋 Planned Enhancements
- Additional zone templates
- Cloud layout syncing (iCloud Drive)
- Custom keyboard shortcuts
- Zone color customization
- Advanced grid editor
- Window history/undo
- Scriptable API

## Contributing

We welcome contributions! Here's how to get started:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure your code:
- Follows Swift style guidelines
- Includes appropriate tests
- Updates documentation as needed

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## Support

### Getting Help

- **GitHub Issues**: [Report bugs or request features](https://github.com/your-org/FancyAreas/issues)
- **Discussions**: [Ask questions and share tips](https://github.com/your-org/FancyAreas/discussions)
- **Documentation**: Check the [docs](docs/) folder

### Before Reporting Issues

1. Check the [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
2. Verify you're running the latest version
3. Confirm permissions are granted (Accessibility + Screen Recording)
4. Check the log file: `~/Library/Logs/FancyAreas/app.log`

## FAQ

**Q: Does FancyAreas work with multiple monitors?**
A: Yes! Full multi-monitor support with independent zones per display.

**Q: How many zones can I create?**
A: Up to 100 zones per layout, though 2-9 zones is optimal for usability.

**Q: Can I use FancyAreas with full-screen apps?**
A: No, macOS full-screen apps cannot be resized. Exit full-screen mode first.

**Q: Does FancyAreas collect any data?**
A: No. FancyAreas runs entirely locally. iCloud sync (if enabled) only syncs preferences through your private iCloud account.

**Q: Is FancyAreas compatible with other window managers?**
A: FancyAreas can coexist with other tools, but using multiple simultaneously may cause conflicts.

See the [User Guide](docs/USER_GUIDE.md) for more FAQs.

## License

FancyAreas is released under the MIT License. See [LICENSE](LICENSE) for details.

## Acknowledgments

Built with:
- Swift & SwiftUI
- AppKit & Cocoa
- Accessibility API
- Combine Framework

Inspired by:
- PowerToys FancyZones (Windows)
- Rectangle (macOS)
- Magnet (macOS)

---

**FancyAreas** - Window management for power users.

Made with ❤️ for the Mac community.