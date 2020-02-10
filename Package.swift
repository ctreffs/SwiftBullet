// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Bullet",
    products: [
        .library(
            name: "Bullet",
            targets: ["Bullet"])
    ],
    targets: [
        .target(
            name: "Bullet",
            dependencies: ["CBullet"]),
        .testTarget(
            name: "BulletTests",
            dependencies: ["Bullet"]),
        .systemLibrary(
            name: "CBullet",
            path: "Sources/CBullet",
            pkgConfig: "bullet",
            providers: [
                .brew(["bullet"]),
                .apt(["libbullet-dev"])
        ])
    ]
)
