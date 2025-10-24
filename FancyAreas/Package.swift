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
            path: "FancyAreas",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "FancyAreasTests",
            dependencies: ["FancyAreas"],
            path: "FancyAreasTests"
        )
    ]
)
