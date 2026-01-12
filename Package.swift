// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AgentFactoryDTO",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "AgentFactoryDTO",
            targets: ["AgentFactoryDTO"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor", .upToNextMajor(from: "4.121.0"))
    ],
    targets: [
        .target(
            name: "AgentFactoryDTO",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ]),
        .testTarget(
            name: "AgentFactoryDTOTests",
            dependencies: ["AgentFactoryDTO"]
        ),
    ]
)
