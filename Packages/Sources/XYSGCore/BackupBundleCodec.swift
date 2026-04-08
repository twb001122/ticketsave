import Foundation

public enum BackupBundleCodecError: LocalizedError, Equatable {
    case missingRequiredFile(fileName: String)

    public var errorDescription: String? {
        switch self {
        case let .missingRequiredFile(fileName):
            return "Missing required backup file: \(fileName)"
        }
    }
}

public struct BackupAssetFile: Sendable, Hashable {
    public let fileName: String
    public let data: Data

    public init(fileName: String, data: Data) {
        self.fileName = fileName
        self.data = data
    }
}

public struct BackupBundlePayload: Sendable, Hashable {
    public let archive: BackupArchive
    public let coverFiles: [BackupAssetFile]

    public init(archive: BackupArchive, coverFiles: [BackupAssetFile]) {
        self.archive = archive
        self.coverFiles = coverFiles
    }
}

public struct BackupBundleCodec {
    public static let manifestFileName = "manifest.json"
    public static let showsFileName = "shows.json"
    public static let performersFileName = "performers.json"
    public static let brandsFileName = "brands.json"
    public static let venuesFileName = "venues.json"
    public static let coversDirectoryName = "covers"

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    public func write(
        _ payload: BackupBundlePayload,
        to directoryURL: URL,
        fileManager: FileManager = .default
    ) throws {
        if fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.removeItem(at: directoryURL)
        }

        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        let coversURL = directoryURL.appendingPathComponent(Self.coversDirectoryName, isDirectory: true)
        try fileManager.createDirectory(at: coversURL, withIntermediateDirectories: true)

        try encoder.encode(payload.archive.manifest).write(to: directoryURL.appendingPathComponent(Self.manifestFileName))
        try encoder.encode(payload.archive.shows).write(to: directoryURL.appendingPathComponent(Self.showsFileName))
        try encoder.encode(payload.archive.performers).write(to: directoryURL.appendingPathComponent(Self.performersFileName))
        try encoder.encode(payload.archive.brands).write(to: directoryURL.appendingPathComponent(Self.brandsFileName))
        try encoder.encode(payload.archive.venues).write(to: directoryURL.appendingPathComponent(Self.venuesFileName))

        for coverFile in payload.coverFiles {
            try coverFile.data.write(to: coversURL.appendingPathComponent(coverFile.fileName))
        }
    }

    public func read(
        from directoryURL: URL,
        fileManager: FileManager = .default
    ) throws -> BackupBundlePayload {
        let manifest = try decodeRequiredFile(
            BackupArchiveManifest.self,
            at: directoryURL.appendingPathComponent(Self.manifestFileName),
            fileName: Self.manifestFileName,
            fileManager: fileManager
        )
        let shows = try decodeRequiredFile(
            [BackupShowRecord].self,
            at: directoryURL.appendingPathComponent(Self.showsFileName),
            fileName: Self.showsFileName,
            fileManager: fileManager
        )
        let performers = try decodeRequiredFile(
            [BackupPerformerRecord].self,
            at: directoryURL.appendingPathComponent(Self.performersFileName),
            fileName: Self.performersFileName,
            fileManager: fileManager
        )
        let brands = try decodeRequiredFile(
            [BackupBrandRecord].self,
            at: directoryURL.appendingPathComponent(Self.brandsFileName),
            fileName: Self.brandsFileName,
            fileManager: fileManager
        )
        let venues = try decodeRequiredFile(
            [BackupVenueRecord].self,
            at: directoryURL.appendingPathComponent(Self.venuesFileName),
            fileName: Self.venuesFileName,
            fileManager: fileManager
        )

        let coversURL = directoryURL.appendingPathComponent(Self.coversDirectoryName, isDirectory: true)
        let coverFiles = try loadCoverFiles(from: coversURL, fileManager: fileManager)
        return BackupBundlePayload(
            archive: BackupArchive(
                manifest: manifest,
                shows: shows,
                performers: performers,
                brands: brands,
                venues: venues
            ),
            coverFiles: coverFiles
        )
    }

    private func decodeRequiredFile<T: Decodable>(
        _ type: T.Type,
        at url: URL,
        fileName: String,
        fileManager: FileManager
    ) throws -> T {
        guard fileManager.fileExists(atPath: url.path) else {
            throw BackupBundleCodecError.missingRequiredFile(fileName: fileName)
        }
        let data = try Data(contentsOf: url)
        return try decoder.decode(type, from: data)
    }

    private func loadCoverFiles(
        from coversURL: URL,
        fileManager: FileManager
    ) throws -> [BackupAssetFile] {
        guard fileManager.fileExists(atPath: coversURL.path) else {
            return []
        }

        let fileURLs = try fileManager.contentsOfDirectory(
            at: coversURL,
            includingPropertiesForKeys: nil
        )

        return try fileURLs
            .filter { !$0.hasDirectoryPath }
            .sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
            .map { url in
                BackupAssetFile(fileName: url.lastPathComponent, data: try Data(contentsOf: url))
            }
    }
}
