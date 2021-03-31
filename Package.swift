// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UnresponsiveCaptureKit",
    platforms: [
        .macOS(.v10_12)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .executable(
            name: "UnresponsiveCapture",
            targets: ["UnresponsiveCapture"]
        ),
        .library(
            name: "UnresponsiveCaptureKit",
            targets: ["UnresponsiveCaptureKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/enums/SwiftyScript", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-tools-support-core", from: "0.1.10")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "UnresponsiveCaptureKit",
            dependencies: [
                "SwiftyScript",
                "SwiftToolsSupport-auto",
            ]),
        .target(
            name: "UnresponsiveCapture",
            dependencies: [
                "SwiftyScript",
                "SwiftToolsSupport-auto",
            ]
        ),
        .testTarget(
            name: "UnresponsiveCaptureKitTests",
            dependencies: ["UnresponsiveCaptureKit"]),
    ]
)
