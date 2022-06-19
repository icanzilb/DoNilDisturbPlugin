import Foundation
import iCalendar

extension String: Error { }

@main class PluginBinary {
    private static var logs = ["#warning(\"logs ⏬\")", "/*", ""]
    static func log(_ string: String?) {
        logs.append(string ?? "nil")
    }

    static func writeLog(at url: URL) throws {
        logs.append("")
        logs.append("*/")
        try logs
            .joined(separator: "\n")
            .write(to: url, atomically: true, encoding: .utf8)
    }

    static func main() throws {
        let invocation = try JSONDecoder().decode(PluginInvocation.self, from: Data(ProcessInfo.processInfo.arguments[1].utf8))

        // Get holiday calendars
        for calPath in invocation.calendarPaths {
            log("Holidays: \(calPath.replacingOccurrences(of: invocation.packagePath + "/", with: ""))")
        }

        let holidayColendars = try invocation.calendarPaths
            .compactMap({
                return Parser.parse(ics: try String(contentsOfFile: $0)).value
            })

        // Write the output
        let outputURL = URL(fileURLWithPath: invocation.sourcePath)

//        let isoDate = "2022-01-01T10:44:00+0000"
//        let dateFormatter = ISO8601DateFormatter()
//        let date = dateFormatter.date(from:isoDate)!

        let date = Date()
        let content = content(for: date, holidayColendars: holidayColendars)
        try content.write(to: outputURL, atomically: true, encoding: .utf8)

        log("Written '\(invocation.sourcePath)'")

        // Write logs
        try writeLog(at: URL(fileURLWithPath: invocation.logPath))
    }

    static func content(for date: Date, holidayColendars: [iCalendar.Calendar]) -> String {
        log("Current date: \(date.debugDescription)")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yy"

        if let holidaySummary = holidayColendars
            .mapFirst(where: { calendar in
                return calendar.events.mapFirst { event in
                    if dateFormatter.string(from: date) == dateFormatter.string(from: event.startDate) {                        log("ITS NOW!")
                        return "It is \(event.summary ?? "a holiday")"
                    }
                    return nil
                }
            }) {
            // Observe holidays
            return content(withReason: holidaySummary)
        }

        if Calendar.current.isDateInWeekend(date) { // Exclude weekend
            return content(withReason: "It's the weekend")
        } else if (9.0...18.0 ~= date.time) { // Your 9-6 basically
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            return content(withReason: "It's \(formatter.string(from: date))")
        }

        return "// All is good, do not disturb is off."
    }

    private static func content(withReason reason: String) -> String {
        "#error(\"Do not disturb is ON\")\n"
            + "#warning(\"\(reason)\")"
    }
}

// https://stackoverflow.com/a/62616907/208205
// https://creativecommons.org/licenses/by-sa/4.0/
extension Date {
    /// time returns a double for which the integer represents the hours from 1 to 24 and the decimal value represents the minutes.
    var time: Double {
        Double(Calendar.current.component(.hour, from: self)) + Double(Calendar.current.component(.minute, from: self)) / 100
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

extension Sequence {
    func mapFirst<T>(where predicate: (Element) throws -> T?) rethrows -> T? {
        for element in self {
            if let result = try predicate(element) {
                return result
            }
        }
        return nil
    }
}
