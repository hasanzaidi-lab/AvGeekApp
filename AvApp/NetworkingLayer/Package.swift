// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AvAppNetworking",
    platforms: [
            .iOS(.v15),       // or higher if you want
            .macOS(.v12),
            .tvOS(.v15),
            .watchOS(.v8)
        ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AvAppNetworking",
            targets: ["AvAppNetworking"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AvAppNetworking"),
        .testTarget(
            name: "AvAppNetworkingTests",
            dependencies: ["AvAppNetworking"]
        ),
    ]
)
