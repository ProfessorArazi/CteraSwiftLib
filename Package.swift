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
    ],
    dependencies: [
        // Reference SwiftExtensions package from local path
        .package(path: "./Dependencies/SwiftExtensions"),
    ],
    targets: [
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
    ]
)
