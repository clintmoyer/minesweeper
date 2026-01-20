// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Minesweeper",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "Minesweeper",
            path: "Sources"
        )
    ]
)
