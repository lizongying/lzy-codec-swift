// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "LzyCodec",
    products: [
        .library(
            name: "LzyCodec",
            targets: ["Lzy"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Lzy",
            path: "Sources/Lzy"),
        .testTarget(
            name: "LzyTests",
            dependencies: ["Lzy"],
            path: "Tests/LzyTests"),
        .executableTarget(
            name: "LzyCodecExample",
            dependencies: ["Lzy"],
            path: "Examples",
            sources: ["example.swift"]
        )
    ]
)
