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
        // Diagnostic build for the in-app window-selection fix. This branch serves the
        // framework straight from the repository, so there is no release, no tag and no
        // checksum to keep in sync. Do not merge: `master` must keep the url + checksum
        // form pointing at a published release.
        .binaryTarget(
            name: "UserComSDK",
            path: "UserComSDK.xcframework"
        )
    ]
)
