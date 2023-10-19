// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PixelfedKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PixelfedKit",
            targets: ["PixelfedKit"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/OAuthSwift/OAuthSwift.git", .upToNextMajor(from: "2.2.0")),
        .package(url: "https://gitlab.com/mflint/HTML2Markdown", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PixelfedKit",
            dependencies: [
                .product(name: "OAuthSwift", package: "OAuthSwift"),
                .product(name: "HTML2Markdown", package: "HTML2Markdown")
            ]
        ),
        .testTarget(
            name: "PixelfedKitTests",
            dependencies: ["PixelfedKit"])
    ]
)
