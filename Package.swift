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
            url: "https://github.com/UserEngage/iOS-SDK/releases/download/0.7.7/UserComSDK.xcframework.zip",
            checksum: "f26a1260a159e6b44fa38b045e2fb9ff6fcc966e212682ae9a91551d16eda9d8"
        )
    ]
)
