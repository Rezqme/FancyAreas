# FancyAreas

A powerful macOS window management application built with Swift and SwiftUI that enables zone-based window snapping and layout management.

## Overview

FancyAreas allows you to define custom zones on your displays and snap windows to them with keyboard modifiers. Save up to 10 different zone layouts and switch between them instantly from the menu bar.

## Key Features

- **Zone-Based Window Snapping**: Define custom zones and snap windows with keyboard modifiers
- **Layout Management**: Save and manage up to 10 zone layouts
- **Multi-Monitor Support**: Independent zone configuration per display
- **Application Restoration**: Launch and position apps automatically (zones + apps mode)
- **Menu Bar Integration**: Quick access to all layouts
- **Keyboard Shortcuts**: Fast layout switching (Cmd+Opt+1-0)
- **iCloud Sync**: Sync layouts across your Macs (planned)

## Development Progress

**Status**: 7 of 32 tasks completed (22%)

### ✅ Completed
- macOS application project structure (Swift Package Manager, Universal Binary)
- Core data models with full Codable support
- File management system with 10-layout limit
- Permission management with first-run setup wizard
- Menu bar integration with dynamic layout list
- Launch on login functionality (macOS 11+)
- Zone detection system with spatial grid optimization (<1ms lookup)

### 🚧 In Progress
- Window drag event monitoring
- Zone overlay visualization
- Window snapping engine
- Preferences window
- Layout management UI
- Zone editor
- Multi-monitor support enhancements

See `FancyAreas/README.md` for detailed architecture and task breakdown.

## System Requirements

- macOS 11.0 (Big Sur) or later
- Apple Silicon or Intel processor (Universal Binary)
- Accessibility permission (for window management)
- Screen Recording permission (for overlay display)

## Building

```bash
cd FancyAreas
swift build
swift run
```

Or open in Xcode:
```bash
cd FancyAreas
open Package.swift
```

## Project Structure

```
FancyAreas/
├── FancyAreas/              # Main application code
│   ├── Models/              # Data models (Layout, Zone, Display, etc.)
│   ├── Controllers/         # Business logic (PermissionsManager, ZoneManager, etc.)
│   ├── Views/               # SwiftUI/AppKit views
│   ├── Utilities/           # Helper classes (LayoutFileManager, etc.)
│   └── Resources/           # Assets and resources
├── FancyAreasTests/         # Unit and integration tests
├── Package.swift            # Swift Package Manager config
└── README.md               # Detailed documentation

FancyAreas Building Task List.md  # Complete task list (32 tasks)
```

## Contributing

This project follows the task list in `FancyAreas Building Task List.md`. All development is tracked through these structured tasks.

## License

Copyright © 2025 FancyAreas. All rights reserved.