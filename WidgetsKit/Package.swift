// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WidgetsKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "WidgetsKit",
            targets: ["WidgetsKit"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/exyte/ActivityIndicatorView.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/divadretlaw/EmojiText", .upToNextMajor(from: "2.6.0")),
        .package(url: "https://github.com/kean/Nuke", .upToNextMajor(from: "12.0.0")),
        .package(name: "PixelfedKit", path: "../PixelfedKit"),
        .package(name: "ClientKit", path: "../ClientKit"),
        .package(name: "ServicesKit", path: "../ServicesKit"),
        .package(name: "EnvironmentKit", path: "../EnvironmentKit")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "WidgetsKit",
            dependencies: [
                .product(name: "ActivityIndicatorView", package: "ActivityIndicatorView"),
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "NukeUI", package: "Nuke"),
                .product(name: "EmojiText", package: "EmojiText"),
                .product(name: "PixelfedKit", package: "PixelfedKit"),
                .product(name: "ClientKit", package: "ClientKit"),
                .product(name: "ServicesKit", package: "ServicesKit"),
                .product(name: "EnvironmentKit", package: "EnvironmentKit")
            ]
        ),
        .testTarget(
            name: "WidgetsKitTests",
            dependencies: ["WidgetsKit"])
    ]
)
