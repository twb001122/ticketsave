import XCTest
@testable import XYSGCore

final class ArchivePaginationStateTests: XCTestCase {
    func testStartsWithFirstPageAtOffsetZero() {
        let state = ArchivePaginationState(pageSize: 20)

        XCTAssertEqual(state.pageSize, 20)
        XCTAssertEqual(state.nextFetchOffset, 0)
        XCTAssertTrue(state.hasMorePages)
        XCTAssertTrue(state.loadedCount == 0)
    }

    func testRegistersFullPageAndAdvancesOffset() {
        var state = ArchivePaginationState(pageSize: 20)

        state.registerLoaded(itemCount: 20)

        XCTAssertEqual(state.loadedCount, 20)
        XCTAssertEqual(state.nextFetchOffset, 20)
        XCTAssertTrue(state.hasMorePages)
    }

    func testRegistersShortPageAndStopsFurtherPaging() {
        var state = ArchivePaginationState(pageSize: 20)

        state.registerLoaded(itemCount: 12)

        XCTAssertEqual(state.loadedCount, 12)
        XCTAssertFalse(state.hasMorePages)
    }

    func testResetReturnsToFirstPage() {
        var state = ArchivePaginationState(pageSize: 20)
        state.registerLoaded(itemCount: 20)
        state.registerLoaded(itemCount: 20)

        state.reset()

        XCTAssertEqual(state.loadedCount, 0)
        XCTAssertEqual(state.nextFetchOffset, 0)
        XCTAssertTrue(state.hasMorePages)
    }
}
