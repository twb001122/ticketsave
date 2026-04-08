import Foundation
import XCTest
@testable import XYSGCore

final class BackupArchiveTests: XCTestCase {
    func testDecodesShowWithMissingFutureFieldsUsingDefaults() throws {
        let json = """
        {
          "id":"AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA",
          "title":"Test Show",
          "performerIDs":["BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB"],
          "format":"standup",
          "myRole":"host",
          "showType":"openMic",
          "createdAt":"1970-01-01T00:00:01Z"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let record = try decoder.decode(BackupShowRecord.self, from: Data(json.utf8))

        XCTAssertEqual(record.title, "Test Show")
        XCTAssertEqual(record.performerIDs.count, 1)
        XCTAssertEqual(record.notes, "")
        XCTAssertEqual(record.tags, [])
        XCTAssertEqual(record.status, .published)
        XCTAssertEqual(record.achievementFlags, [])
    }

    func testBackupArchiveRoundTripsWithManifest() throws {
        let archive = BackupArchive(
            manifest: BackupArchiveManifest(
                exportedAt: Date(timeIntervalSince1970: 123),
                appVersion: "1.0",
                counts: BackupArchiveCounts(shows: 1, performers: 1, brands: 1, venues: 1)
            ),
            shows: [
                BackupShowRecord(
                    id: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
                    title: "Midnight Laughs",
                    coverFileName: "cover-a.jpg",
                    date: Date(timeIntervalSince1970: 99),
                    venueID: UUID(uuidString: "DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD"),
                    brandID: UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC"),
                    performerIDs: [UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!],
                    format: .standup,
                    myRole: .performer,
                    showType: .showcase,
                    notes: "note",
                    tags: ["a"],
                    createdAt: Date(timeIntervalSince1970: 88),
                    updatedAt: Date(timeIntervalSince1970: 99),
                    status: .published,
                    achievementFlags: ["first_show"]
                )
            ],
            performers: [
                BackupPerformerRecord(
                    id: UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!,
                    displayName: "Alex",
                    normalizedKey: "alex",
                    stageName: nil,
                    avatarFileName: nil,
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ],
            brands: [
                BackupBrandRecord(
                    id: UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC")!,
                    displayName: "Comedy Club",
                    normalizedKey: "comedy club",
                    cityName: "Shanghai",
                    accentColorHex: nil,
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ],
            venues: [
                BackupVenueRecord(
                    id: UUID(uuidString: "DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD")!,
                    displayName: "The Vault",
                    normalizedKey: "the vault",
                    lookupKey: "the vault::shanghai",
                    addressLine: nil,
                    district: nil,
                    cityName: "Shanghai",
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ]
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(archive)
        let decoded = try JSONDecoder().decode(BackupArchive.self, from: data)

        XCTAssertEqual(decoded.manifest.schemaVersion, BackupArchiveVersion.currentSchemaVersion)
        XCTAssertEqual(decoded.manifest.counts.shows, 1)
        XCTAssertEqual(decoded.shows.first?.title, "Midnight Laughs")
        XCTAssertEqual(decoded.performers.first?.displayName, "Alex")
    }
}
