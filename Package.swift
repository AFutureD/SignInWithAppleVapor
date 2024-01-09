// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SignInWithAppleVapor",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SignInWithAppleVapor",
            targets: ["SignInWithAppleVapor"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SignInWithAppleVapor",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "JWT", package: "JWT"),
            ]
        ),
        .testTarget(
            name: "SignInWithAppleVaporTests",
            dependencies: [
                "SignInWithAppleVapor",
                .product(name: "XCTVapor", package: "vapor")
            ]
        ),
    ]
)
