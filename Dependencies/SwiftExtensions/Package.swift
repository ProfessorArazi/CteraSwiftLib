// swift-tools-version:5.5
import PackageDescription

let dep = Target.Dependency.product(name: "SimpleEncryptor", package: "CryptoExtensions")

let package = Package(
    name: "SwiftExtensions",
    platforms: [.iOS(.v13), .macOS(.v11)],
    products: [
        .library(name: "BasicExtensions", targets: ["BasicExtensions"]),
        .library(name: "StorageExtensions", targets: ["StorageExtensions"]),  // Export StorageExtensions as a product
    ],
    dependencies: [
        .package(path: "../CryptoExtensions"), // Reference CryptoExtensions package from local path
    ],
    targets: [
        .target(name: "BasicExtensions"),
        .target(name: "StorageExtensions", dependencies: ["BasicExtensions", dep]),
        .testTarget(name: "BasicExtensionsTests", dependencies: ["BasicExtensions"]),
        .testTarget(name: "StorageTests", dependencies: ["BasicExtensions", "StorageExtensions"]),
    ]
)
