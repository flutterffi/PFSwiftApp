// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PFSwiftApp",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v14)
    ],
    products: [
        .executable(name: "PFSwiftApp", targets: ["PFSwiftApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.2"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.25.5")
    ],
    targets: [
        .executableTarget(
            name: "PFSwiftApp",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            resources: [
                .process("Resources")
            ],
            plugins: [
                .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")
            ]
        ),
        .testTarget(
            name: "PFSwiftAppTests",
            dependencies: [
                "PFSwiftApp",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        )
    ]
)
