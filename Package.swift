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
            url: "https://github.com/UserEngage/iOS-SDK/releases/download/1.1.0/UserComSDK.xcframework.zip",
            checksum: "abf9dbf1bf21fb635366759e8dae7d8f9a7eafd31bbb435674b87c65ca03afbf"
        )
    ]
)
