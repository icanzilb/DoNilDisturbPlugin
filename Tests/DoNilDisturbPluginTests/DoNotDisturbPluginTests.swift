import XCTest
import Foundation
import iCalendar

@testable import PluginBinary

final class DoNotDisturbPluginTests: XCTestCase {
    
    func testHolidayLoad() throws {
        let date = Foundation.Calendar.current.date(from: DateComponents(year: 2022, month: 8, day: 30, hour: 13))!
        let path = #filePath
        let parent = (path as NSString).deletingLastPathComponent
        let icalPath = parent.appending("/TestCal.ics")
        let icalContents = try String(contentsOfFile: icalPath)
        let parseResult = Parser.parse(ics: icalContents)
        switch parseResult {
        case .success(let calendar):
            let content = PluginBinary.content(for: date, holidayColendars: [calendar])
            XCTAssertEqual(content,
"""
#error("Do not disturb is ON")
#warning("It is The Feast of Maximum Occupancy")
""")
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }
    
    func testWeekendError() throws {
        let sunday = Calendar.current.date(from: DateComponents(year: 2022, month: 08, day: 28))!
        
        let content = PluginBinary.content(for: sunday, holidayColendars: [])
        XCTAssertEqual(content,
"""
#error("Do not disturb is ON")
#warning("It's the weekend")
""")
    }
    
    func test2amError() {
        var calendar = Foundation.Calendar.current
        
        // Prevents errors when the calendar is in a different locale
        calendar.locale = Locale(identifier: "en-US")
        
        let monday2am = calendar.date(from: DateComponents(year: 2022, month: 08, day: 29, hour: 2))!
        
        let content = PluginBinary.content(for: monday2am,
                                           holidayColendars: [],
                                           systemCalendar: calendar)
        XCTAssertEqual(content,
"""
#error("Do not disturb is ON")
#warning("It's 2:00 AM")
""")
    }
    
    func testWorkTime() {
        let monday2pm = Calendar.current.date(from: DateComponents(year: 2022, month: 08, day: 29, hour: 14))!
        let content = PluginBinary.content(for: monday2pm, holidayColendars: [])
        XCTAssertEqual(content, "// All is good, do not disturb is off.")
    }
    
    
}
