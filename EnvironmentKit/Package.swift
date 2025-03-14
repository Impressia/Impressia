// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EnvironmentKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "EnvironmentKit",
            targets: ["EnvironmentKit"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "ClientKit", path: "../ClientKit")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "EnvironmentKit",
            dependencies: [
                .product(name: "ClientKit", package: "ClientKit")
            ]
        ),
        .testTarget(
            name: "EnvironmentKitTests",
            dependencies: ["EnvironmentKit"])
    ]
)
