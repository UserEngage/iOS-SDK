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
            url: "https://github.com/UserEngage/iOS-SDK/releases/download/1.0.0/UserComSDK.xcframework.zip",
            checksum: "e089cfe95e532648ac8bd764a802d1aaa614d2f4a0fedc626d5f198171920e92"
        )
    ]
)
