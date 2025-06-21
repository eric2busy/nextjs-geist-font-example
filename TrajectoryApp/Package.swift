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
        .executable(
            name: "TrajectoryDemo",
            targets: ["TrajectoryDemo"]),
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
        .executableTarget(
            name: "TrajectoryDemo",
            dependencies: ["TrajectoryApp"],
            path: "Sources/TrajectoryApp/Preview",
            sources: ["SampleApp.swift"]
        ),
        .testTarget(
            name: "TrajectoryAppTests",
            dependencies: ["TrajectoryApp"]),
    ]
)
