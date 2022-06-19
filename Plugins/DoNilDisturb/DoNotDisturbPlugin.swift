import Foundation
import PackagePlugin

@main
struct DoNilDisturb: BuildToolPlugin {

    func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        let output = context.pluginWorkDirectory.appending(["DND.swift"])
        let log = context.pluginWorkDirectory.appending(["log.swift"])
        let files = try holidaysFileURLs(context: context)

        let invocation = PluginInvocation(
            packagePath: context.package.directory.string,
            logPath: log.string,
            sourcePath: output.string,
            calendarPaths: files.map(\.string)
        )

        return [
            .buildCommand(
                displayName: "Do Not Disturb",
                executable: try context.tool(named: "PluginBinary").path,
                arguments: [try invocation.encodedString()],
                outputFiles: [output, log]
            )
        ]
    }

    func holidaysFileURLs(context: PackagePlugin.PluginContext) throws -> [Path] {
        let directory = context.package.directory.appending([".config"])
        print("Config directory: \(directory)")
        guard let enumerator = FileManager.default.enumerator(atPath: directory.string) else {
            return []
        }

        var result = [Path]()
        while let filePath = enumerator.nextObject() as? String {
            if filePath.hasSuffix(".ics") {
                result.append(directory.appending([filePath]))
            }
        }
        return result
    }
}

struct PluginInvocation: Codable {
    let packagePath: String
    let logPath: String
    let sourcePath: String
    let calendarPaths: [String]

    func encodedString() throws -> String {
        let data = try JSONEncoder().encode(self)
        return String(decoding: data, as: UTF8.self)
    }
}
