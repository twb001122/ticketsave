import Foundation
import SwiftData
import XYSGCore

struct LocalBackupSnapshot {
    let manifest: BackupArchiveManifest
}

enum LocalBackupArchiveError: LocalizedError {
    case invalidArchive

    var errorDescription: String? {
        switch self {
        case .invalidArchive:
            return "这个 zip 备份无法识别，确认它是从 XYSG 导出的完整备份。"
        }
    }
}

@MainActor
struct LocalBackupArchiveService {
    private let fileManager: FileManager
    private let archiveMapper: BackupArchiveMapper
    private let zipCodec: BackupZipCodec

    init(
        fileManager: FileManager = .default,
        archiveMapper: BackupArchiveMapper = BackupArchiveMapper(),
        zipCodec: BackupZipCodec = BackupZipCodec()
    ) {
        self.fileManager = fileManager
        self.archiveMapper = archiveMapper
        self.zipCodec = zipCodec
    }

    func exportDocument(in context: ModelContext) throws -> LocalBackupArchiveDocument {
        let shows = try context.fetch(FetchDescriptor<ShowRecord>())
        let performers = try context.fetch(FetchDescriptor<Performer>())
        let brands = try context.fetch(FetchDescriptor<ProductionBrand>())
        let venues = try context.fetch(FetchDescriptor<Venue>())
        let payload = try archiveMapper.makePayload(
            shows: shows,
            performers: performers,
            brands: brands,
            venues: venues,
            appVersion: appVersionString
        )
        let data = try zipCodec.data(for: payload, fileManager: fileManager)
        return LocalBackupArchiveDocument(data: data, manifest: payload.archive.manifest)
    }

    func restore(
        from archiveURL: URL,
        in context: ModelContext
    ) throws -> LocalBackupSnapshot {
        let shouldStopAccessing = archiveURL.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                archiveURL.stopAccessingSecurityScopedResource()
            }
        }

        let payload = try zipCodec.read(from: archiveURL, fileManager: fileManager)
        guard payload.archive.manifest.schemaVersion > 0 else {
            throw LocalBackupArchiveError.invalidArchive
        }
        try archiveMapper.restore(payload: payload, in: context)
        return LocalBackupSnapshot(manifest: payload.archive.manifest)
    }

    private var appVersionString: String {
        let bundle = Bundle.main
        let marketingVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let buildNumber = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(marketingVersion) (\(buildNumber))"
    }
}
