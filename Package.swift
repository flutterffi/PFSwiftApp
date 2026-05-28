// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PFSwiftApp",
    platforms: [
        .iOS(.v16),
        .macOS(.v14)
    ],
    products: [
        .executable(name: "PFSwiftApp", targets: ["PFSwiftApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.25.5")
    ],
    targets: [
        .executableTarget(
            name: "PFSwiftApp",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
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
