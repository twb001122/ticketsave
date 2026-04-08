import XCTest
@testable import XYSGCore

final class EntityLookupKeyTests: XCTestCase {
    func testNormalizesWhitespaceAndCaseForSharedEntities() {
        XCTAssertEqual(EntityLookupKey.performer("  Alice   Wong  "), "alice wong")
        XCTAssertEqual(EntityLookupKey.brand("Center   Stage "), "center stage")
    }

    func testKeepsDisplaySpecificVenueCitiesOutOfNameKey() {
        XCTAssertEqual(
            EntityLookupKey.venue(name: " The Obsidian Vault ", city: " Shanghai "),
            "the obsidian vault::shanghai"
        )
        XCTAssertEqual(EntityLookupKey.venue(name: "The Obsidian Vault", city: nil), "the obsidian vault")
    }

    func testCollapsesNewlinesTabsAndFullWidthSpacing() {
        XCTAssertEqual(
            EntityLookupKey.brand("  某某\t 喜剧\n 俱乐部  "),
            "某某 喜剧 俱乐部"
        )
    }
}
