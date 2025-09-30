// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UserComSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "UserComSDK",
            targets: ["UserSDKTargets"]),
    ],
     dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0"),
        .package(url: "https://github.com/kaishin/Gifu.git", exact: "3.3.1")
    ],
    targets: [
        .binaryTarget(
            name: "UserSDKBinary",
            path: "UserComSDK.xcframework"
        ),
        .target(
            name: "UserSDKTargets",
            dependencies: [
                .target(name: "UserSDKBinary"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "Gifu", package: "Gifu")
            ],
            path: "Sources/UserSDKTargets"
        ),
    ]
)
