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
            url: "https://github.com/UserEngage/iOS-SDK/releases/download/0.7.12/UserComSDK.xcframework.zip",
            checksum: "aac3948fcb84632bbecdf4d82781bd6457193cc0aa7d20f92ba674517b0dae8b"
        )
    ]
)
