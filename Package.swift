// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UserDefaultsConcurrency",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "UserDefaultsConcurrency",
            targets: ["UserDefaultsConcurrency"]
        )
    ],
    targets: [
        .target(
            name: "UserDefaultsConcurrency"
        ),
        .testTarget(
            name: "UserDefaultsConcurrencyTests",
            dependencies: ["UserDefaultsConcurrency"]
        )
    ]
)
