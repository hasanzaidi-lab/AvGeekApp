// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AvAppNetworking",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "AvAppNetworking",
            targets: ["AvAppNetworking"]
        ),
    ],
    targets: [
        .target(
            name: "AvAppNetworking"
        ),
        .testTarget(
            name: "AvAppNetworkingTests",
            dependencies: ["AvAppNetworking"],
            resources: [
                .process("Fixtures")
            ]
        ),
    ]
)
