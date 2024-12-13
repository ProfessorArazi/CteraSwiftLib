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
        .library(name: "SwiftExtensions", targets: ["StorageExtensions", "BasicExtensions", "CBC", "SimpleEncryptor"]),
    ],
    dependencies: [],
    targets: [
        // Define individual targets for the components
        .target(name: "CteraUtil", dependencies: ["StorageExtensions", "BasicExtensions", "CBC", "SimpleEncryptor"]),
        .target(name: "CteraModels", dependencies: ["StorageExtensions", "BasicExtensions", "CteraUtil", "CBC", "SimpleEncryptor"]),
        .target(name: "CteraCache", dependencies: ["StorageExtensions", "BasicExtensions", "CteraModels", "CteraUtil", "CBC", "SimpleEncryptor"]),
        .target(name: "CteraNetwork", dependencies: ["StorageExtensions", "BasicExtensions", "CteraCache", "CteraModels", "CteraUtil", "CBC", "SimpleEncryptor"]),

        // Define SwiftExtensions sub-targets
        .target(name: "StorageExtensions", dependencies: ["BasicExtensions", "CBC", "SimpleEncryptor"]),
        .target(name: "BasicExtensions"),

        // Define CBC and SimpleEncryptor as separate local targets
        .target(
                    name: "CBC",
                    dependencies: []),
                .target(
                    name: "SimpleEncryptor",
                    dependencies: ["CBC"]),
        // Test targets
        .testTarget(name: "CteraNetworkTests", dependencies: ["CteraNetwork", "CteraCache"]),
        .testTarget(name: "CteraUtilTests", dependencies: ["CteraUtil"]),
    ]
)
