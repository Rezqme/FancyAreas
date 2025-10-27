// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FancyAreas",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(
            name: "FancyAreas",
            targets: ["FancyAreas"]
        )
    ],
    dependencies: [
        // Add package dependencies here if needed
    ],
    targets: [
        .executableTarget(
            name: "FancyAreas",
            dependencies: [],
            path: ".",
            exclude: [
                "FancyAreasTests",
                "docs",
                ".build",
                "FancyAreas",
                "README.md",
                "Info.plist",
                ".gitignore"
            ]
        ),
        .testTarget(
            name: "FancyAreasTests",
            dependencies: ["FancyAreas"],
            path: "FancyAreasTests"
        )
    ]
)
