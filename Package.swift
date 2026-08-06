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
            url: "https://github.com/UserEngage/iOS-SDK/releases/download/1.1.1/UserComSDK.xcframework.zip",
            checksum: "0695c9895d650db577a84a69f84590df6324ff9ef8c280707a120f1ac5954e63"
        )
    ]
)
