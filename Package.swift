// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DigimonTokenTamer",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "DigimonTokenTamer",
            path: "Sources/DigimonTokenTamer",
            resources: [.copy("Resources/Tamer")],
            linkerSettings: [.linkedLibrary("sqlite3")]
        ),
        .testTarget(
            name: "DigimonTokenTamerTests",
            dependencies: ["DigimonTokenTamer"],
            path: "Tests/DigimonTokenTamerTests"
        ),
    ]
)
