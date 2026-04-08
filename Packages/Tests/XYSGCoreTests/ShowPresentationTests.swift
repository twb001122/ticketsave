import XCTest
@testable import XYSGCore

final class ShowPresentationTests: XCTestCase {
    func testUsesFallbackTitleWhenRawTitleIsBlank() {
        XCTAssertEqual(ShowPresentation.storedTitle(from: ""), ShowPresentation.untitledShowName)
        XCTAssertEqual(ShowPresentation.storedTitle(from: "   "), ShowPresentation.untitledShowName)
    }

    func testPreservesMeaningfulTitleAfterTrimming() {
        XCTAssertEqual(ShowPresentation.storedTitle(from: "  午夜拼盘  "), "午夜拼盘")
    }

    func testFormatsCompactCardDateTimeLabel() {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.year = 2026
        components.month = 4
        components.day = 9
        components.hour = 21
        components.minute = 30

        let date = components.date!
        XCTAssertEqual(
            ShowPresentation.compactCardDateTime(from: date),
            "APR 9 · 21:30"
        )
    }

    func testBuildsCardMetadataLines() {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.year = 2026
        components.month = 4
        components.day = 9
        components.hour = 21
        components.minute = 30

        let date = components.date!
        let metadata = ShowPresentation.cardMetadata(date: date, formatDisplayName: "单口")

        XCTAssertEqual(metadata.primaryLine, "APR 9 · 21:30")
        XCTAssertEqual(metadata.secondaryLine, "单口")
    }
}
