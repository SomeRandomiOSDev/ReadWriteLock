// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "ReadWriteLock",

    platforms: [
        .iOS("9.0"),
        .macOS("10.10"),
        .tvOS("9.0"),
        .watchOS("2.0")
    ],

    products: [
        .library(name: "ReadWriteLock", targets: ["ReadWriteLock"])
    ],

    targets: [
        .target(name: "ReadWriteLock"),
        .testTarget(name: "ReadWriteLockTests", dependencies: ["ReadWriteLock"])
    ],

    swiftLanguageVersions: [.version("5")]
)
