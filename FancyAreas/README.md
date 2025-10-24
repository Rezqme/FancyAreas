# FancyAreas - macOS Window Management Application

A powerful macOS window management application built with Swift and SwiftUI that enables zone-based window snapping and layout management.

## Features

- **Zone-Based Window Snapping**: Define custom zones on your displays and snap windows to them with keyboard modifiers
- **Layout Management**: Save up to 10 different zone layouts and switch between them instantly
- **Multi-Monitor Support**: Configure independent zones for each display
- **Application Restoration**: Save not just zones, but which apps go in which zones
- **iCloud Sync**: Sync your layouts and preferences across all your Macs
- **Menu Bar Integration**: Quick access to all layouts from the menu bar
- **Keyboard Shortcuts**: Fast layout switching with customizable shortcuts

## System Requirements

- macOS 11.0 (Big Sur) or later
- Apple Silicon or Intel processor (Universal Binary)
- Accessibility permission (for window management)
- Screen Recording permission (for overlay display)

## Project Structure

```
FancyAreas/
├── FancyAreas/
│   ├── FancyAreasApp.swift      # Main app entry point
│   ├── Models/                   # Data models
│   ├── Views/                    # SwiftUI and AppKit views
│   ├── Controllers/              # Managers and controllers
│   ├── Utilities/                # Helper classes and extensions
│   ├── Resources/                # Assets, icons, etc.
│   └── Info.plist               # App configuration
├── FancyAreasTests/             # Unit and integration tests
├── Package.swift                 # Swift Package Manager configuration
└── README.md                    # This file
```

## Building

This project uses Swift Package Manager:

```bash
swift build
swift run
```

For Xcode:
```bash
open Package.swift
```

## Permissions Setup

FancyAreas requires the following permissions:

1. **Accessibility**: System Preferences > Security & Privacy > Privacy > Accessibility
2. **Screen Recording**: System Preferences > Security & Privacy > Privacy > Screen Recording
3. **Automation**: Granted automatically when controlling specific applications

## Development Status

See the main task list for detailed implementation progress.

## License

Copyright © 2025 FancyAreas. All rights reserved.
