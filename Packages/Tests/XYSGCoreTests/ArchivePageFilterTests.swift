import Foundation
import XCTest
@testable import XYSGCore

final class ArchivePageFilterTests: XCTestCase {
    func testPagesRecordsBySelectedFormat() {
        let records = [
            makeRecord(dayOffset: 0, format: .standup),
            makeRecord(dayOffset: 1, format: .improv),
            makeRecord(dayOffset: 2, format: .standup),
            makeRecord(dayOffset: 3, format: .improv),
        ]

        let result = ArchivePageFilter.pageIDs(
            from: records,
            filters: ArchiveQueryFilters(selectedFormat: .improv, selectedBrandID: nil),
            offset: 0,
            limit: 20
        )

        XCTAssertEqual(result, [records[1].id, records[3].id])
    }

    func testPagesRecordsByBrandAndFormat() {
        let targetBrand = UUID()
        let otherBrand = UUID()
        let records = [
            makeRecord(dayOffset: 0, format: .standup, brandID: targetBrand),
            makeRecord(dayOffset: 1, format: .improv, brandID: targetBrand),
            makeRecord(dayOffset: 2, format: .improv, brandID: otherBrand),
            makeRecord(dayOffset: 3, format: .improv, brandID: targetBrand),
        ]

        let result = ArchivePageFilter.pageIDs(
            from: records,
            filters: ArchiveQueryFilters(selectedFormat: .improv, selectedBrandID: targetBrand),
            offset: 0,
            limit: 20
        )

        XCTAssertEqual(result, [records[1].id, records[3].id])
    }

    func testAppliesOffsetAndLimitAfterFiltering() {
        let records = [
            makeRecord(dayOffset: 0, format: .standup),
            makeRecord(dayOffset: 1, format: .standup),
            makeRecord(dayOffset: 2, format: .standup),
        ]

        let result = ArchivePageFilter.pageIDs(
            from: records,
            filters: ArchiveQueryFilters(selectedFormat: .standup, selectedBrandID: nil),
            offset: 1,
            limit: 1
        )

        XCTAssertEqual(result, [records[1].id])
    }

    private func makeRecord(dayOffset: Int, format: ShowFormat, brandID: UUID? = nil) -> ArchivePageRecord {
        ArchivePageRecord(
            id: UUID(),
            updatedAt: Calendar.current.date(byAdding: .day, value: dayOffset, to: .distantPast) ?? .distantPast,
            format: format,
            brandID: brandID
        )
    }
}
