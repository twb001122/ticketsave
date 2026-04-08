import Foundation
import XCTest
@testable import XYSGCore

final class PersistentStoreRecoveryTests: XCTestCase {
    func testMovesStoreSidecarFilesIntoRecoveryDirectory() throws {
        let fileManager = FileManager.default
        let rootURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: rootURL, withIntermediateDirectories: true)

        let storeURL = rootURL.appendingPathComponent("default.store")
        let walURL = rootURL.appendingPathComponent("default.store-wal")
        let shmURL = rootURL.appendingPathComponent("default.store-shm")
        let unrelatedURL = rootURL.appendingPathComponent("notes.txt")

        try Data("store".utf8).write(to: storeURL)
        try Data("wal".utf8).write(to: walURL)
        try Data("shm".utf8).write(to: shmURL)
        try Data("notes".utf8).write(to: unrelatedURL)

        let recovered = try PersistentStoreRecovery().recoverStoreFiles(
            at: rootURL,
            baseFileName: "default.store"
        )

        XCTAssertEqual(recovered.movedFiles.map(\.lastPathComponent).sorted(), [
            "default.store",
            "default.store-shm",
            "default.store-wal",
        ])
        XCTAssertTrue(fileManager.fileExists(atPath: unrelatedURL.path))
        XCTAssertFalse(fileManager.fileExists(atPath: storeURL.path))
        XCTAssertTrue(fileManager.fileExists(atPath: recovered.recoveryDirectoryURL.path))
    }

    func testReturnsEmptyResultWhenNoStoreFilesExist() throws {
        let fileManager = FileManager.default
        let rootURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: rootURL, withIntermediateDirectories: true)

        let recovered = try PersistentStoreRecovery().recoverStoreFiles(
            at: rootURL,
            baseFileName: "default.store"
        )

        XCTAssertTrue(recovered.movedFiles.isEmpty)
        XCTAssertEqual(recovered.recoveryDirectoryURL.lastPathComponent, "Recovery")
    }

    func testRelocatesEntireDirectoryIntoRecoveryArea() throws {
        let fileManager = FileManager.default
        let parentURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        let dataDirectoryURL = parentURL.appendingPathComponent("XYSG", isDirectory: true)
        try fileManager.createDirectory(at: dataDirectoryURL, withIntermediateDirectories: true)
        try Data("store".utf8).write(to: dataDirectoryURL.appendingPathComponent("default.store"))
        try Data("cover".utf8).write(to: dataDirectoryURL.appendingPathComponent("cache.bin"))

        let recovered = try PersistentStoreRecovery().relocateDirectory(
            at: dataDirectoryURL,
            fileManager: fileManager
        )

        XCTAssertTrue(fileManager.fileExists(atPath: dataDirectoryURL.path))
        XCTAssertEqual(
            try fileManager.contentsOfDirectory(at: dataDirectoryURL, includingPropertiesForKeys: nil).count,
            0
        )
        XCTAssertTrue(fileManager.fileExists(atPath: recovered.relocatedDirectoryURL.appendingPathComponent("default.store").path))
        XCTAssertTrue(fileManager.fileExists(atPath: recovered.relocatedDirectoryURL.appendingPathComponent("cache.bin").path))
    }
}
