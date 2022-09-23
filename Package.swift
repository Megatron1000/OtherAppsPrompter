// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OtherAppsPrompter",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "OtherAppsPrompter",
            targets: ["OtherAppsPrompter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/rhodgkins/SwiftHTTPStatusCodes", from: "3.3.0"),
        .package(url: "https://github.com/onevcat/Kingfisher", from: "7.3.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "OtherAppsPrompter",
            dependencies: [
                .product(name: "HTTPStatusCodes", package: "SwiftHTTPStatusCodes"),
                .product(name: "Kingfisher", package: "Kingfisher")
            ],
            resources: [
                  .process("Resources/Assets.xcassets"),
                  .process("Resources/OtherAppsPrompter.storyboard"),
            ]),
    ]
)
