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
            url: "https://github.com/UserEngage/iOS-SDK/releases/download/1.3.0/UserComSDK.xcframework.zip",
            checksum: "156d930750d7f4c252f5d8a9908489038cfdb08f5c0f4ea30758d50adb65e52d"
        )
    ]
)
