// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "NoNotch",
    platforms: [
        .macOS(.v12)
    ],
    targets: [
        .executableTarget(
            name: "NoNotch",
            path: "Sources/NoNotch",
            resources: [
                .copy("Resources")
            ]
        )
    ]
)
