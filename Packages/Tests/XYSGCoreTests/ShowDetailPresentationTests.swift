import XCTest
@testable import XYSGCore

final class ShowDetailPresentationTests: XCTestCase {
    func testBuildsCompactDateHighlightContent() {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.year = 2026
        components.month = 4
        components.day = 5
        components.hour = 19
        components.minute = 30

        let content = ShowDetailPresentation.dateHighlightContent(for: components.date)

        XCTAssertEqual(content.primary, "Apr 5")
        XCTAssertEqual(content.secondary, "19:30")
    }

    func testBuildsVenueAndLocationHighlightContent() {
        let venue = ShowDetailPresentation.venueHighlightContent(
            venueName: "趣空间",
            district: "朝阳区",
            cityName: "北京"
        )
        let location = ShowDetailPresentation.locationHighlightContent(
            cityName: "北京",
            district: "朝阳区"
        )

        XCTAssertEqual(venue.primary, "趣空间")
        XCTAssertEqual(venue.secondary, "朝阳区")
        XCTAssertEqual(location.primary, "朝阳区")
        XCTAssertEqual(location.secondary, "北京")
    }

    func testBuildsLocationSummaryFromCityAndDistrict() {
        XCTAssertEqual(
            ShowDetailPresentation.locationSummary(cityName: "北京", district: "朝阳"),
            "北京 · 朝阳"
        )
    }

    func testUsesPlaceholdersForMissingHighlightContent() {
        XCTAssertEqual(
            ShowDetailPresentation.dateTimeValue(for: nil),
            ShowDetailPresentation.pendingDateTimeLabel
        )
        XCTAssertEqual(
            ShowDetailPresentation.venueValue(venueName: nil),
            ShowDetailPresentation.pendingVenueLabel
        )
        XCTAssertEqual(
            ShowDetailPresentation.locationSummary(cityName: nil, district: nil),
            ShowDetailPresentation.pendingLocationLabel
        )
    }

    func testBuildsAdditionalRowsInExpectedOrder() {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.year = 2026
        components.month = 4
        components.day = 9
        components.hour = 21
        components.minute = 30

        let rows = ShowDetailPresentation.additionalRows(
            formatDisplayName: "单口",
            roleDisplayName: "演员",
            showTypeDisplayName: "商演",
            brandName: "喜剧俱乐部",
            updatedAt: components.date!
        )

        XCTAssertEqual(rows.map(\.title), ["内容形式", "我的角色", "演出属性", "厂牌", "最后更新"])
        XCTAssertEqual(rows[0].value, "单口")
        XCTAssertEqual(rows[3].value, "喜剧俱乐部")
        XCTAssertEqual(rows[4].title, "最后更新")
    }
}
