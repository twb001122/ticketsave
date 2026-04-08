import XCTest
@testable import XYSGCore

final class ShowEnumsTests: XCTestCase {
    func testShowRoleIncludesOtherCase() {
        XCTAssertTrue(ShowRole.allCases.contains(.other))
        XCTAssertEqual(ShowRole.other.displayName, "其他")
    }

    func testShowTypeIncludesOtherCase() {
        XCTAssertTrue(ShowType.allCases.contains(.other))
        XCTAssertEqual(ShowType.other.displayName, "其他")
    }

    func testArchiveStatsSummaryCountsOtherRoleAndType() {
        let records = [
            ShowStatsRecord(
                date: nil,
                format: .other,
                role: .other,
                showType: .other,
                brandID: nil
            )
        ]

        let summary = ArchiveStatsSummaryCalculator.makeSummary(from: records)

        XCTAssertEqual(summary.roleCounts[.other], 1)
        XCTAssertEqual(summary.typeCounts[.other], 1)
        XCTAssertEqual(summary.formatCounts[.other], 1)
    }

    func testShowFormatAccentTokensAreStable() {
        XCTAssertEqual(ShowFormat.standup.accentToken, .sun)
        XCTAssertEqual(ShowFormat.manzai.accentToken, .berry)
        XCTAssertEqual(ShowFormat.improv.accentToken, .mint)
        XCTAssertEqual(ShowFormat.sketch.accentToken, .sky)
        XCTAssertEqual(ShowFormat.other.accentToken, .fog)
    }
}
