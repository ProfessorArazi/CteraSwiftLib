// swift-tools-version:5.5
import PackageDescription

// Define the dependency for SimpleEncryptor from the CryptoExtensions package
let dep = Target.Dependency.product(name: "SimpleEncryptor", package: "CryptoExtensions")

let package = Package(
    name: "SwiftExtensions",
    platforms: [.iOS(.v13), .macOS(.v11)],
    products: [
        // Export BasicExtensions as a library
        .library(name: "BasicExtensions", targets: ["BasicExtensions"]),
        
        // Export StorageExtensions as a library
        .library(name: "StorageExtensions", targets: ["StorageExtensions"]),
    ],
    dependencies: [
        // Reference CryptoExtensions from the local path
        .package(path: "../CryptoExtensions"), // Adjust this path if needed
    ],
    targets: [
        // BasicExtensions target (no dependencies)
        .target(name: "BasicExtensions"),
        
        // StorageExtensions target depends on BasicExtensions and SimpleEncryptor from CryptoExtensions
        .target(name: "StorageExtensions", dependencies: ["BasicExtensions", dep]),
        
        // Tests for BasicExtensions
        .testTarget(name: "BasicExtensionsTests", dependencies: ["BasicExtensions"]),
        
        // Tests for StorageExtensions (depends on both BasicExtensions and StorageExtensions)
        .testTarget(name: "StorageTests", dependencies: ["BasicExtensions", "StorageExtensions"]),
    ]
)
