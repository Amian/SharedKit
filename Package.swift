// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SharedUIKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "DesignSystem",
            targets: ["DesignSystem", "AppBrowser"]
        ),
        .library(
            name: "FirebaseKit",
            targets: ["FirebaseKit"]
        ),
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
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            from: "11.2.0"
        ),
    ],
    targets: [
        .target(
            name: "DesignSystem"
        ),
        .target(
            name: "FirebaseKit",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
            ]
        ),
        .target(
            name: "Paywall",
            dependencies: [
                "DesignSystem",
                .product(name: "RevenueCat", package: "purchases-ios"),
            ]
        ),
        .target(
            name: "Onboarding",
            dependencies: [
                "DesignSystem"
            ]
        ),
        .target(
            name: "AppBrowser",
            dependencies: [
                "DesignSystem"
            ]
        ),
    ]
)
