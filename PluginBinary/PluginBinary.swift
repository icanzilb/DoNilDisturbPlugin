import Foundation

extension String: Error { }

@main class PluginBinary {
    static func main() throws {
        let outputURL = URL(fileURLWithPath: ProcessInfo.processInfo.arguments[1])

        let content = content(for: Date())

        try content.write(to: outputURL, atomically: true, encoding: .utf8)
    }

    static func content(for date: Date) -> String {
        let content: String

        if (false == Calendar.current.isDateInWeekend(date) && // Exclude weekend
            9.0...18.0 ~= date.time) { // Your 9-6 basically
            // Working hours
            content = "// All is good, do not disturb is off."
        } else {
            // DND
            content = #"#error("Do not disturb is ON")"#
        }

        return content
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
