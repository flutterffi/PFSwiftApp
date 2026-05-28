// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "PFSwiftApp",
    defaultLocalization: "en",
    platforms: [
        .iOS("18.0"),
        .macOS("15.0")
    ],
    products: [
        .executable(name: "PFSwiftApp", targets: ["PFSwiftApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.2"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.25.5")
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
    ],
    swiftLanguageModes: [.v6]
)
