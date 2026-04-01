// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "UserComSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "UserComSDK",
            targets: ["UserComSDK"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0"),
        .package(url: "https://github.com/kaishin/Gifu.git", exact: "3.3.1")
    ],
    targets: [
        .binaryTarget(
            name: "UserComSDKBinary",
            url: "https://github.com/UserEngage/iOS-SDK/releases/download/0.7.8/UserComSDK.xcframework.zip",
            checksum: "aac3948fcb84632bbecdf4d82781bd6457193cc0aa7d20f92ba674517b0dae8b"
        ),
        .target(
            name: "UserComSDK",
            dependencies: [
                .target(name: "UserComSDKBinary"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "Gifu", package: "Gifu")
            ],
            path: "Sources/UserComSDKTargets"
        )
    ]
)
