// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "DoNilDisturbPlugin",
    platforms: [
        .macOS(.v11),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v8)
    ],
    products: [
        .plugin(name: "DoNilDisturbPlugin", targets: ["DoNilDisturb"])
    ],
    dependencies: [
        .package(url: "https://github.com/icanzilb/iCalendar.git", from: "0.0.1")
    ],
    targets: [
        // Your app or library
        .executableTarget(
            name: "MyApp",
            plugins: [
                .plugin(name: "DoNilDisturb")
            ]
        ),
        // Your plugin's IMPLEMENTATION
        .executableTarget(
            name: "PluginBinary",
            dependencies: [
                .product(name: "iCalendar", package: "iCalendar")
            ],
            path: "PluginBinary"
        ),
        // Your plugin's INTERFACE
        .plugin(
            name: "DoNilDisturb",
            capability: .buildTool(),
            dependencies: [
                .target(name: "PluginBinary")
            ]
        ),
        .testTarget(
            name: "DoNilDisturbPluginTests",
            dependencies: [
                .target(name: "PluginBinary"),
                .product(name: "iCalendar", package: "iCalendar")
            ],
            resources: [
                .copy("Resources"),
            ]
        )
    ]
)
