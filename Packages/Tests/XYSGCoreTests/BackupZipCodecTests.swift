import Foundation
import XCTest
@testable import XYSGCore

final class BackupZipCodecTests: XCTestCase {
    func testRoundTripsPayloadThroughZipArchive() throws {
        let codec = BackupZipCodec()
        let payload = BackupBundlePayload(
            archive: BackupArchive(
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
            ),
            coverFiles: [
                BackupAssetFile(fileName: "cover-a.jpg", data: Data("cover-a".utf8))
            ]
        )
        let archiveURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("zip")

        try codec.write(payload, to: archiveURL)
        let restored = try codec.read(from: archiveURL)

        XCTAssertEqual(restored.archive, payload.archive)
        XCTAssertEqual(restored.coverFiles, payload.coverFiles)
    }
}
