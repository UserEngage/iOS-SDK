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
            url: "https://github.com/UserEngage/iOS-SDK/releases/download/1.2.0/UserComSDK.xcframework.zip",
            checksum: "b2ee2a3e754c97ec2a0798f700087c07faa0cea672332bb659cd34e553ce1f83"
        )
    ]
)
