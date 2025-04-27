// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StoreKitHelper",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v15),
        .watchOS(.v8),
        .visionOS(.v1),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "StoreKitHelper",
            targets: ["StoreKitHelper"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/rive-app/rive-ios", from: "6.5.6"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "StoreKitHelper",
            dependencies: [
                .product(name: "RiveRuntime", package: "rive-ios"),
            ],
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)
