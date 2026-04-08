import Foundation
import XCTest
@testable import XYSGCore

final class BackupBundleCodecTests: XCTestCase {
    func testWritesAndReadsBundlePayloadWithCoverFiles() throws {
        let payload = BackupBundlePayload(
            archive: sampleArchive(),
            coverFiles: [
                BackupAssetFile(fileName: "cover-a.jpg", data: Data("cover-a".utf8)),
                BackupAssetFile(fileName: "cover-b.jpg", data: Data("cover-b".utf8)),
            ]
        )
        let codec = BackupBundleCodec()
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        try codec.write(payload, to: rootURL)
        let restored = try codec.read(from: rootURL)

        XCTAssertEqual(restored.archive.manifest, payload.archive.manifest)
        XCTAssertEqual(restored.archive.shows, payload.archive.shows)
        XCTAssertEqual(restored.coverFiles.map(\.fileName).sorted(), ["cover-a.jpg", "cover-b.jpg"])
        XCTAssertEqual(restored.coverFiles.first(where: { $0.fileName == "cover-a.jpg" })?.data, Data("cover-a".utf8))
    }

    func testReadFailsWhenManifestIsMissing() throws {
        let codec = BackupBundleCodec()
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)

        XCTAssertThrowsError(try codec.read(from: rootURL)) { error in
            guard case let BackupBundleCodecError.missingRequiredFile(fileName) = error else {
                return XCTFail("Expected missingRequiredFile, got \(error)")
            }
            XCTAssertEqual(fileName, "manifest.json")
        }
    }

    private func sampleArchive() -> BackupArchive {
        BackupArchive(
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
                    brandIDs: [UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC")!],
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
                    performerIDs: [UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!],
                    venueIDs: [UUID(uuidString: "DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD")!],
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
                    performerIDs: [UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!],
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ]
        )
    }
}
