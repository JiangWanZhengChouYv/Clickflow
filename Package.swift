// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Clickflow",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Clickflow", targets: ["Clickflow"])
    ],
    targets: [
        .executableTarget(
            name: "Clickflow",
            path: "Sources/Clickflow"
        )
    ]
)
