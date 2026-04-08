// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XYSGCore",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "XYSGCore",
            targets: ["XYSGCore"]
        ),
    ],
    targets: [
        .target(
            name: "XYSGCore"
        ),
        .testTarget(
            name: "XYSGCoreTests",
            dependencies: ["XYSGCore"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
