// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CteraSwiftLib",
    defaultLocalization: "en",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "CteraSwiftLib",
            targets: ["CteraNetwork", "CteraModels", "CteraUtil", "CteraCache"]
        ),
        // Add export for BasicExtensions and StorageExtensions if needed
        .library(
            name: "BasicExtensions",
            targets: ["BasicExtensions"]
        ),
        .library(
            name: "StorageExtensions",
            targets: ["StorageExtensions"]
        ),
    ],
    dependencies: [
        // Reference SwiftExtensions package from local path
        .package(path: "./Dependencies/SwiftExtensions"),
    ],
    targets: [
        // BasicExtensions and StorageExtensions should be properly added as targets here
        .target(
            name: "CteraUtil",
            dependencies: [
                .product(name: "BasicExtensions", package: "SwiftExtensions"),
                .product(name: "StorageExtensions", package: "SwiftExtensions"),
            ],
            resources: [.process("Resources/")]
        ),
        .target(
            name: "CteraModels",
            dependencies: [
                .product(name: "BasicExtensions", package: "SwiftExtensions"),
                .product(name: "StorageExtensions", package: "SwiftExtensions"),
                "CteraUtil",
            ]
        ),
        .target(
            name: "CteraCache",
            dependencies: [
                .product(name: "BasicExtensions", package: "SwiftExtensions"),
                .product(name: "StorageExtensions", package: "SwiftExtensions"),
                "CteraUtil",
                "CteraModels",
            ]
        ),
        .target(
            name: "CteraNetwork",
            dependencies: [
                .product(name: "BasicExtensions", package: "SwiftExtensions"),
                .product(name: "StorageExtensions", package: "SwiftExtensions"),
                "CteraModels",
                "CteraUtil",
                "CteraCache",
            ]
        ),
        // Export BasicExtensions and StorageExtensions
        .target(
            name: "BasicExtensions",
            path: "./Dependencies/SwiftExtensions/Sources/BasicExtensions"
        ),
        .target(
            name: "StorageExtensions",
            dependencies: ["BasicExtensions"],
            path: "./Dependencies/SwiftExtensions/Sources/StorageExtensions"
        ),
        .target(
            name: "SwiftExtensions",
            path: "./Dependencies/SwiftExtensions/Sources" // Path to the local SwiftExtensions source files
        ),
        .testTarget(
            name: "CteraNetworkTests",
            dependencies: ["CteraNetwork", "CteraCache"]
        ),
        .testTarget(
            name: "CteraUtilTests",
            dependencies: ["CteraUtil"]
        ),
        .testTarget(
            name: "BasicExtensionsTests",
            dependencies: ["BasicExtensions"],
            path: "./Tests/BasicExtensionsTests" // Specify the custom path for BasicExtensionsTests
        ),
        .testTarget(
            name: "StorageExtensionsTests",
            dependencies: ["StorageExtensions"],
            path: "./Tests/StorageExtensionsTests" // Specify the custom path for StorageExtensionsTests
        ),
    ]
)
