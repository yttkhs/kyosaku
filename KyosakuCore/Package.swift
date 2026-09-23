// swift-tools-version: 6.2
import PackageDescription

let upcomingFeatures: [SwiftSetting] = [
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
]

let package = Package(
    name: "KyosakuCore",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "KyosakuCore", targets: ["KyosakuCore"])
    ],
    targets: [
        .target(name: "KyosakuCore", swiftSettings: upcomingFeatures),
        .testTarget(
            name: "KyosakuCoreTests",
            dependencies: ["KyosakuCore"],
            swiftSettings: upcomingFeatures
        ),
    ],
    swiftLanguageModes: [.v6]
)
