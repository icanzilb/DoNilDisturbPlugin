import Foundation
import PackagePlugin

@main
struct DoNilDisturb: BuildToolPlugin {

    func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        let output = context.pluginWorkDirectory.appending(["DND.swift"])

        return [
            .buildCommand(
                displayName: "Do Not Disturb",
                executable: try context.tool(named: "PluginBinary").path,
                arguments: [output.string],
                outputFiles: [output]
            )
        ]
    }
}
