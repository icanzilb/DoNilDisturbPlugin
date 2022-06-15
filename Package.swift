// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "DoNotDisturbPlugin",
    platforms: [.macOS(.v12)],
    products: [
        .plugin(name: "DoNilDisturbPlugin", targets: ["DoNilDisturb"])
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
            path: "PluginBinary"
        ),
        // Your plugin's INTERFACE
        .plugin(
            name: "DoNilDisturb",
            capability: .buildTool(),
            dependencies: [
                .target(name: "PluginBinary")
            ]
        )
    ]
)
