// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "CteraSwiftLib",
    defaultLocalization: "en", // Set default localization to English or your preferred language
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        // Export CteraSwiftLib main library
        .library(name: "CteraSwiftLib", targets: ["CteraNetwork", "CteraModels", "CteraUtil", "CteraCache"]),
        // Export SwiftExtensions library as a product
        .library(name: "SwiftExtensions", targets: ["StorageExtensions", "BasicExtensions"]),
        .library(name: "CryptoExtensions", targets: ["CryptoExtensions"])
    ],
    dependencies: [],
    targets: [
        // Define individual targets for the components
        .target(
            name: "CteraUtil",
            dependencies: ["StorageExtensions", "BasicExtensions", "CryptoExtensions"]
        ),
        .target(
            name: "CteraModels",
            dependencies: ["StorageExtensions", "BasicExtensions", "CteraUtil", "CryptoExtensions"]
        ),
        .target(
            name: "CteraCache",
            dependencies: ["StorageExtensions", "BasicExtensions", "CteraModels", "CteraUtil", "CryptoExtensions"]
        ),
        .target(
            name: "CteraNetwork",
            dependencies: ["StorageExtensions", "BasicExtensions", "CteraCache", "CteraModels", "CteraUtil", "CryptoExtensions"]
        ),

        // Define SwiftExtensions sub-targets
        .target(
            name: "StorageExtensions",
            dependencies: ["BasicExtensions", "CryptoExtensions"]
        ),
        .target(
            name: "BasicExtensions"
        ),

        // Define CryptoExtensions as a single target including its subfolders like CBC
        .target(
            name: "CryptoExtensions",
            dependencies: []
        ),

        // Test targets
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
