import Foundation

public enum BackupZipCodecError: LocalizedError {
    case invalidArchive
    case missingEndOfCentralDirectory
    case unsupportedCompressionMethod(UInt16)
    case missingEntry(String)

    public var errorDescription: String? {
        switch self {
        case .invalidArchive:
            return "The zip archive is invalid."
        case .missingEndOfCentralDirectory:
            return "The zip archive is missing its central directory."
        case let .unsupportedCompressionMethod(method):
            return "Unsupported zip compression method: \(method)"
        case let .missingEntry(name):
            return "Missing zip entry: \(name)"
        }
    }
}

public struct BackupZipCodec {
    private let bundleCodec: BackupBundleCodec

    public init(bundleCodec: BackupBundleCodec = BackupBundleCodec()) {
        self.bundleCodec = bundleCodec
    }

    public func write(
        _ payload: BackupBundlePayload,
        to archiveURL: URL,
        fileManager: FileManager = .default
    ) throws {
        let archiveData = try data(for: payload, fileManager: fileManager)
        if fileManager.fileExists(atPath: archiveURL.path) {
            try fileManager.removeItem(at: archiveURL)
        }
        try archiveData.write(to: archiveURL, options: .atomic)
    }

    public func read(
        from archiveURL: URL,
        fileManager: FileManager = .default
    ) throws -> BackupBundlePayload {
        let data = try Data(contentsOf: archiveURL)
        return try read(from: data, fileManager: fileManager)
    }

    public func data(
        for payload: BackupBundlePayload,
        fileManager: FileManager = .default
    ) throws -> Data {
        let tempDirectoryURL = fileManager.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let bundleDirectoryURL = tempDirectoryURL.appendingPathComponent("Bundle", isDirectory: true)

        try fileManager.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true)
        try bundleCodec.write(payload, to: bundleDirectoryURL, fileManager: fileManager)
        defer { try? fileManager.removeItem(at: tempDirectoryURL) }

        let entryDataByPath = try loadEntryData(from: bundleDirectoryURL, fileManager: fileManager)
        return makeZipArchive(from: entryDataByPath)
    }

    public func read(
        from data: Data,
        fileManager: FileManager = .default
    ) throws -> BackupBundlePayload {
        let tempDirectoryURL = fileManager.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempDirectoryURL) }

        let entries = try parseZipArchive(data)
        try writeEntries(entries, into: tempDirectoryURL, fileManager: fileManager)
        return try bundleCodec.read(from: tempDirectoryURL, fileManager: fileManager)
    }

    private func loadEntryData(
        from directoryURL: URL,
        fileManager: FileManager
    ) throws -> [(path: String, data: Data)] {
        let relativePaths = try fileManager.subpathsOfDirectory(atPath: directoryURL.path).sorted()
        var fileURLs: [URL] = []
        for relativePath in relativePaths {
            let fileURL = directoryURL.appendingPathComponent(relativePath)
            let isDirectory = try fileURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory ?? false
            if !isDirectory {
                fileURLs.append(fileURL)
            }
        }

        return try fileURLs.map { fileURL in
            let relativePath = String(fileURL.path.dropFirst(directoryURL.path.count + 1))
            return (relativePath, try Data(contentsOf: fileURL))
        }
    }

    private func writeEntries(
        _ entries: [String: Data],
        into directoryURL: URL,
        fileManager: FileManager
    ) throws {
        for (relativePath, data) in entries {
            let destinationURL = directoryURL.appendingPathComponent(relativePath)
            let parentURL = destinationURL.deletingLastPathComponent()
            try fileManager.createDirectory(at: parentURL, withIntermediateDirectories: true)
            try data.write(to: destinationURL, options: .atomic)
        }
    }

    private func makeZipArchive(from entries: [(path: String, data: Data)]) -> Data {
        var archiveData = Data()
        var centralDirectory = Data()
        var localHeaderOffsets: [UInt32] = []
        let utf8Flag: UInt16 = 0x0800

        for entry in entries {
            let fileNameData = Data(entry.path.utf8)
            let crc = crc32(of: entry.data)
            let localHeaderOffset = UInt32(archiveData.count)
            localHeaderOffsets.append(localHeaderOffset)

            archiveData.appendLittleEndian(UInt32(0x04034B50))
            archiveData.appendLittleEndian(UInt16(20))
            archiveData.appendLittleEndian(utf8Flag)
            archiveData.appendLittleEndian(UInt16(0))
            archiveData.appendLittleEndian(UInt16(0))
            archiveData.appendLittleEndian(UInt16(0))
            archiveData.appendLittleEndian(crc)
            archiveData.appendLittleEndian(UInt32(entry.data.count))
            archiveData.appendLittleEndian(UInt32(entry.data.count))
            archiveData.appendLittleEndian(UInt16(fileNameData.count))
            archiveData.appendLittleEndian(UInt16(0))
            archiveData.append(fileNameData)
            archiveData.append(entry.data)

            centralDirectory.appendLittleEndian(UInt32(0x02014B50))
            centralDirectory.appendLittleEndian(UInt16(20))
            centralDirectory.appendLittleEndian(UInt16(20))
            centralDirectory.appendLittleEndian(utf8Flag)
            centralDirectory.appendLittleEndian(UInt16(0))
            centralDirectory.appendLittleEndian(UInt16(0))
            centralDirectory.appendLittleEndian(UInt16(0))
            centralDirectory.appendLittleEndian(crc)
            centralDirectory.appendLittleEndian(UInt32(entry.data.count))
            centralDirectory.appendLittleEndian(UInt32(entry.data.count))
            centralDirectory.appendLittleEndian(UInt16(fileNameData.count))
            centralDirectory.appendLittleEndian(UInt16(0))
            centralDirectory.appendLittleEndian(UInt16(0))
            centralDirectory.appendLittleEndian(UInt16(0))
            centralDirectory.appendLittleEndian(UInt16(0))
            centralDirectory.appendLittleEndian(UInt32(0))
            centralDirectory.appendLittleEndian(localHeaderOffset)
            centralDirectory.append(fileNameData)
        }

        let centralDirectoryOffset = UInt32(archiveData.count)
        archiveData.append(centralDirectory)
        archiveData.appendLittleEndian(UInt32(0x06054B50))
        archiveData.appendLittleEndian(UInt16(0))
        archiveData.appendLittleEndian(UInt16(0))
        archiveData.appendLittleEndian(UInt16(entries.count))
        archiveData.appendLittleEndian(UInt16(entries.count))
        archiveData.appendLittleEndian(UInt32(centralDirectory.count))
        archiveData.appendLittleEndian(centralDirectoryOffset)
        archiveData.appendLittleEndian(UInt16(0))
        return archiveData
    }

    private func parseZipArchive(_ data: Data) throws -> [String: Data] {
        let endRecordOffset = try findEndOfCentralDirectory(in: data)
        let centralDirectoryEntryCount = Int(data.readUInt16(at: endRecordOffset + 10))
        let centralDirectorySize = Int(data.readUInt32(at: endRecordOffset + 12))
        let centralDirectoryOffset = Int(data.readUInt32(at: endRecordOffset + 16))
        guard centralDirectoryOffset + centralDirectorySize <= data.count else {
            throw BackupZipCodecError.invalidArchive
        }

        var entries: [String: Data] = [:]
        var cursor = centralDirectoryOffset

        for _ in 0..<centralDirectoryEntryCount {
            guard data.readUInt32(at: cursor) == 0x02014B50 else {
                throw BackupZipCodecError.invalidArchive
            }

            let compressionMethod = data.readUInt16(at: cursor + 10)
            guard compressionMethod == 0 else {
                throw BackupZipCodecError.unsupportedCompressionMethod(compressionMethod)
            }

            let compressedSize = Int(data.readUInt32(at: cursor + 20))
            let fileNameLength = Int(data.readUInt16(at: cursor + 28))
            let extraFieldLength = Int(data.readUInt16(at: cursor + 30))
            let fileCommentLength = Int(data.readUInt16(at: cursor + 32))
            let localHeaderOffset = Int(data.readUInt32(at: cursor + 42))

            let fileNameStart = cursor + 46
            let fileNameEnd = fileNameStart + fileNameLength
            guard fileNameEnd <= data.count else {
                throw BackupZipCodecError.invalidArchive
            }

            let fileName = String(decoding: data[fileNameStart..<fileNameEnd], as: UTF8.self)
            let fileData = try readFileData(
                named: fileName,
                in: data,
                localHeaderOffset: localHeaderOffset,
                expectedCompressedSize: compressedSize
            )
            entries[fileName] = fileData

            cursor = fileNameEnd + extraFieldLength + fileCommentLength
        }

        return entries
    }

    private func readFileData(
        named fileName: String,
        in data: Data,
        localHeaderOffset: Int,
        expectedCompressedSize: Int
    ) throws -> Data {
        guard data.readUInt32(at: localHeaderOffset) == 0x04034B50 else {
            throw BackupZipCodecError.invalidArchive
        }

        let compressionMethod = data.readUInt16(at: localHeaderOffset + 8)
        guard compressionMethod == 0 else {
            throw BackupZipCodecError.unsupportedCompressionMethod(compressionMethod)
        }

        let fileNameLength = Int(data.readUInt16(at: localHeaderOffset + 26))
        let extraFieldLength = Int(data.readUInt16(at: localHeaderOffset + 28))
        let dataStart = localHeaderOffset + 30 + fileNameLength + extraFieldLength
        let dataEnd = dataStart + expectedCompressedSize
        guard dataEnd <= data.count else {
            throw BackupZipCodecError.missingEntry(fileName)
        }

        return Data(data[dataStart..<dataEnd])
    }

    private func findEndOfCentralDirectory(in data: Data) throws -> Int {
        let minimumSize = 22
        guard data.count >= minimumSize else {
            throw BackupZipCodecError.missingEndOfCentralDirectory
        }

        let maxCommentLength = 65_535
        let searchStart = max(0, data.count - minimumSize - maxCommentLength)
        for offset in stride(from: data.count - minimumSize, through: searchStart, by: -1) {
            if data.readUInt32(at: offset) == 0x06054B50 {
                return offset
            }
        }

        throw BackupZipCodecError.missingEndOfCentralDirectory
    }

    private func crc32(of data: Data) -> UInt32 {
        var crc: UInt32 = 0xFFFF_FFFF
        for byte in data {
            let index = Int((crc ^ UInt32(byte)) & 0xFF)
            crc = BackupZipCRCTable.table[index] ^ (crc >> 8)
        }
        return crc ^ 0xFFFF_FFFF
    }
}

private enum BackupZipCRCTable {
    static let table: [UInt32] = {
        (0..<256).map { value in
            var crc = UInt32(value)
            for _ in 0..<8 {
                if (crc & 1) == 1 {
                    crc = 0xEDB8_8320 ^ (crc >> 1)
                } else {
                    crc >>= 1
                }
            }
            return crc
        }
    }()
}

private extension Data {
    mutating func appendLittleEndian(_ value: UInt16) {
        var littleEndian = value.littleEndian
        Swift.withUnsafeBytes(of: &littleEndian) { buffer in
            append(buffer.bindMemory(to: UInt8.self))
        }
    }

    mutating func appendLittleEndian(_ value: UInt32) {
        var littleEndian = value.littleEndian
        Swift.withUnsafeBytes(of: &littleEndian) { buffer in
            append(buffer.bindMemory(to: UInt8.self))
        }
    }

    func readUInt16(at offset: Int) -> UInt16 {
        let range = offset..<(offset + 2)
        return subdata(in: range).withUnsafeBytes { $0.load(as: UInt16.self) }.littleEndian
    }

    func readUInt32(at offset: Int) -> UInt32 {
        let range = offset..<(offset + 4)
        return subdata(in: range).withUnsafeBytes { $0.load(as: UInt32.self) }.littleEndian
    }
}
