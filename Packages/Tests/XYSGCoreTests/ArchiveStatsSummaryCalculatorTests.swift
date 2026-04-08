import Foundation
import XCTest
@testable import XYSGCore

final class ArchiveStatsSummaryCalculatorTests: XCTestCase {
    func testComputesCountsAcrossFormatRoleAndShowType() {
        let brandA = UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!
        let brandB = UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!

        let records = [
            ShowStatsRecord(
                date: Date(timeIntervalSince1970: 1_700_000_000),
                format: .standup,
                role: .host,
                showType: .openMic,
                brandID: brandA
            ),
            ShowStatsRecord(
                date: Date(timeIntervalSince1970: 1_800_000_000),
                format: .standup,
                role: .performer,
                showType: .special,
                brandID: brandA
            ),
            ShowStatsRecord(
                date: Date(timeIntervalSince1970: 1_750_000_000),
                format: .improv,
                role: .headliner,
                showType: .commercial,
                brandID: brandB
            ),
        ]

        let summary = ArchiveStatsSummaryCalculator.makeSummary(from: records)

        XCTAssertEqual(summary.totalShows, 3)
        XCTAssertEqual(summary.latestShowDate, Date(timeIntervalSince1970: 1_800_000_000))
        XCTAssertEqual(summary.formatCounts[.standup], 2)
        XCTAssertEqual(summary.formatCounts[.improv], 1)
        XCTAssertEqual(summary.roleCounts[.host], 1)
        XCTAssertEqual(summary.roleCounts[.performer], 1)
        XCTAssertEqual(summary.roleCounts[.headliner], 1)
        XCTAssertEqual(summary.typeCounts[.openMic], 1)
        XCTAssertEqual(summary.typeCounts[.special], 1)
        XCTAssertEqual(summary.typeCounts[.commercial], 1)
        XCTAssertEqual(summary.brandCounts[brandA], 2)
        XCTAssertEqual(summary.brandCounts[brandB], 1)
    }

    func testHandlesEmptyInput() {
        let summary = ArchiveStatsSummaryCalculator.makeSummary(from: [])
        XCTAssertEqual(summary.totalShows, 0)
        XCTAssertNil(summary.latestShowDate)
        XCTAssertTrue(summary.formatCounts.isEmpty)
        XCTAssertTrue(summary.roleCounts.isEmpty)
        XCTAssertTrue(summary.typeCounts.isEmpty)
        XCTAssertTrue(summary.brandCounts.isEmpty)
    }

    func testIgnoresMissingDatesWhenComputingLatestShowDate() {
        let records = [
            ShowStatsRecord(
                date: nil,
                format: .standup,
                role: .performer,
                showType: .showcase,
                brandID: nil
            ),
            ShowStatsRecord(
                date: Date(timeIntervalSince1970: 1_900_000_000),
                format: .improv,
                role: .host,
                showType: .commercial,
                brandID: nil
            ),
        ]

        let summary = ArchiveStatsSummaryCalculator.makeSummary(from: records)

        XCTAssertEqual(summary.latestShowDate, Date(timeIntervalSince1970: 1_900_000_000))
    }
}
