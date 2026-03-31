// swift-tools-version:5.5
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
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "UserComSDK",
            url: "https://github.com/UserEngage/iOS-SDK/releases/download/0.7.6/UserComSDK.xcframework.zip",
            checksum: "9ad58c6ae254d8776f1b19522118c7a2474c6826a238720a1a3fbcf820d4a286"
        )
    ]
)
