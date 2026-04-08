import Foundation
import XCTest
@testable import XYSGCore

final class CoverImageStoreTests: XCTestCase {
    func testImportsDataIntoManagedDirectory() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        let store = CoverImageStore(baseURL: root)

        let relativePath = try store.importImageData(Data([0x01, 0x02, 0x03]), fileExtension: "jpg")
        let savedURL = root.appendingPathComponent(relativePath)

        XCTAssertTrue(FileManager.default.fileExists(atPath: savedURL.path()))
        XCTAssertEqual(try Data(contentsOf: savedURL), Data([0x01, 0x02, 0x03]))
    }

    func testReplacesPreviousAssetAndRemovesOldFile() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        let store = CoverImageStore(baseURL: root)

        let oldRelativePath = try store.importImageData(Data([0x0A]), fileExtension: "png")
        let newRelativePath = try store.replaceImageData(
            Data([0x0B, 0x0C]),
            replacing: oldRelativePath,
            fileExtension: "jpg"
        )

        XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(newRelativePath).path()))
        XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent(oldRelativePath).path()))
    }

    func testKeepsReferencedFilesWhenCleaningUnusedAssets() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        let store = CoverImageStore(baseURL: root)

        let kept = try store.importImageData(Data([0x01]), fileExtension: "jpg")
        let removed = try store.importImageData(Data([0x02]), fileExtension: "jpg")

        try store.pruneUnusedAssets(referencedPaths: [kept])

        XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(kept).path()))
        XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent(removed).path()))
    }
}
