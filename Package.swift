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
        // Pre-release test build of 1.1.2 (in-app in its own window, in-app received in
        // the background shown on next activation). This branch serves the framework
        // straight from the repository, so there is no release, no tag and no checksum to
        // keep in sync. Do not merge: `master` must keep the url + checksum form pointing
        // at a published release.
        .binaryTarget(
            name: "UserComSDK",
            path: "UserComSDK.xcframework"
        )
    ]
)
