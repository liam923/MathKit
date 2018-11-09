// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MathKit",
    products: [
        .library(
            name: "MathKit",
            targets: ["MathKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MathKit",
            dependencies: []),
        .testTarget(
            name: "MathKitTests",
            dependencies: ["MathKit"]),
    ]
)
