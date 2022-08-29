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

        let holidayCalendars = try invocation.calendarPaths
            .compactMap({
                return Parser.parse(ics: try String(contentsOfFile: $0)).value
            })

        // Write the output
        let outputURL = URL(fileURLWithPath: invocation.sourcePath)

//        let isoDate = "2022-01-01T10:44:00+0000"
//        let dateFormatter = ISO8601DateFormatter()
//        let date = dateFormatter.date(from:isoDate)!

        let date = Date()
        let content = content(for: date, holidayCalendars: holidayCalendars)
        try content.write(to: outputURL, atomically: true, encoding: .utf8)

        log("Written '\(invocation.sourcePath)'")

        // Write logs
        try writeLog(at: URL(fileURLWithPath: invocation.logPath))
    }

    static func content(for date: Date, holidayCalendars: [iCalendar.Calendar], systemCalendar: Foundation.Calendar = .current) -> String {
        log("Current date: \(date.debugDescription)")

        if let holidaySummary = holidayCalendars
            .mapFirst(where: { calendar in
                return calendar.events.mapFirst { event in
                    // iCalendar creates dates for all-day things at noon rather than midnight, so we need to compare date components instead of dates
                    let startDateComponents = systemCalendar.dateComponents([.year, .month, .day], from: event.startDate)
                    let currentDateComponents = systemCalendar.dateComponents([.year, .month, .day], from: date)
                    if startDateComponents.year == currentDateComponents.year,
                       startDateComponents.month == currentDateComponents.month,
                       startDateComponents.day == currentDateComponents.day {
                        log("ITS NOW!")
                        return "It is \(event.summary ?? "a holiday")"
                    }
                    return nil
                }
            }) {
            // Observe holidays
            return content(withReason: holidaySummary)
        }

        if systemCalendar.isDateInWeekend(date) { // Exclude weekend
            return content(withReason: "It's the weekend")
        } else if (9.0...18.0 ~= date.time) {
            // Time is in the 9am-6pm range
            return "// All is good, do not disturb is off."
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = systemCalendar.locale
        
        return content(withReason: "It's \(formatter.string(from: date))")
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
