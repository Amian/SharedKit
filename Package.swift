// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SharedUIKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "Paywall",
            targets: ["Paywall"]
        ),
        .library(
            name: "Onboarding",
            targets: ["Onboarding"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/RevenueCat/purchases-ios.git",
            from: "4.33.0"
        ),
    ],
    targets: [
        .target(
            name: "Paywall",
            dependencies: [
                .product(name: "RevenueCat", package: "purchases-ios"),
            ]
        ),
        .target(
            name: "Onboarding"
        ),
    ]
)
