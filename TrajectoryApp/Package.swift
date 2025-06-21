// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TrajectoryApp",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "TrajectoryApp",
            targets: ["TrajectoryApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "0.3.0")
    ],
    targets: [
        .target(
            name: "TrajectoryApp",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ]
        ),
        .testTarget(
            name: "TrajectoryAppTests",
            dependencies: ["TrajectoryApp"]),
    ]
)
