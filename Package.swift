// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "CombineExt",
    products: [
        .library(
            name: "CombineExt",
            targets: ["CombineExt"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CombineExt",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "CombineExtTests",
            dependencies: ["CombineExt"],
            path: "Tests"
        ),
    ]
)
