// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RasterizeXCAssets",
    products: [
        .executable(name: "rasterizexcassets", targets: ["RasterizeXCAssets"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/Commander", from: "0.8.0"),
        .package(url: "https://github.com/LinusU/JSBridge", from: "1.0.0-alpha.7"),
    ],
    targets: [
        .target(name: "RasterizeXCAssets", dependencies: ["Commander", "JSBridge"]),
    ]
)
