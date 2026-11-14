// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DigimonTokenTamer",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "DigimonTokenTamer",
            path: "Sources/DigimonTokenTamer",
            // catalog.json is compiled in (scripts/gen-catalog.sh): a resource bundle would embed the
            // absolute build path in the binary through the generated Bundle.module accessor.
            exclude: ["Resources"],
            linkerSettings: [.linkedLibrary("sqlite3")]
        ),
        .testTarget(
            name: "DigimonTokenTamerTests",
            dependencies: ["DigimonTokenTamer"],
            path: "Tests/DigimonTokenTamerTests"
        ),
    ]
)
