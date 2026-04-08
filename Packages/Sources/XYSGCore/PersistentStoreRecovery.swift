import Foundation

public struct PersistentStoreRecoveryResult: Sendable, Hashable {
    public let recoveryDirectoryURL: URL
    public let movedFiles: [URL]

    public init(recoveryDirectoryURL: URL, movedFiles: [URL]) {
        self.recoveryDirectoryURL = recoveryDirectoryURL
        self.movedFiles = movedFiles
    }
}

public struct PersistentDirectoryRecoveryResult: Sendable, Hashable {
    public let recoveryDirectoryURL: URL
    public let relocatedDirectoryURL: URL

    public init(recoveryDirectoryURL: URL, relocatedDirectoryURL: URL) {
        self.recoveryDirectoryURL = recoveryDirectoryURL
        self.relocatedDirectoryURL = relocatedDirectoryURL
    }
}

public struct PersistentStoreRecovery {
    public init() {}

    public func recoverStoreFiles(
        at directoryURL: URL,
        baseFileName: String,
        fileManager: FileManager = .default
    ) throws -> PersistentStoreRecoveryResult {
        let recoveryDirectoryURL = directoryURL.appendingPathComponent("Recovery", isDirectory: true)
        let candidateURLs = try existingStoreFiles(
            at: directoryURL,
            baseFileName: baseFileName,
            fileManager: fileManager
        )

        guard !candidateURLs.isEmpty else {
            return PersistentStoreRecoveryResult(
                recoveryDirectoryURL: recoveryDirectoryURL,
                movedFiles: []
            )
        }

        let timestampDirectoryURL = recoveryDirectoryURL
            .appendingPathComponent(timestampToken(), isDirectory: true)
        try fileManager.createDirectory(at: timestampDirectoryURL, withIntermediateDirectories: true)

        var movedFiles: [URL] = []
        for sourceURL in candidateURLs {
            let destinationURL = timestampDirectoryURL.appendingPathComponent(sourceURL.lastPathComponent)
            try fileManager.moveItem(at: sourceURL, to: destinationURL)
            movedFiles.append(destinationURL)
        }

        return PersistentStoreRecoveryResult(
            recoveryDirectoryURL: recoveryDirectoryURL,
            movedFiles: movedFiles
        )
    }

    public func relocateDirectory(
        at directoryURL: URL,
        fileManager: FileManager = .default
    ) throws -> PersistentDirectoryRecoveryResult {
        let recoveryDirectoryURL = directoryURL.deletingLastPathComponent()
            .appendingPathComponent("\(directoryURL.lastPathComponent)-Recovery", isDirectory: true)
        let relocatedDirectoryURL = recoveryDirectoryURL
            .appendingPathComponent(timestampToken(), isDirectory: true)

        guard fileManager.fileExists(atPath: directoryURL.path) else {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            return PersistentDirectoryRecoveryResult(
                recoveryDirectoryURL: recoveryDirectoryURL,
                relocatedDirectoryURL: relocatedDirectoryURL
            )
        }

        try fileManager.createDirectory(at: recoveryDirectoryURL, withIntermediateDirectories: true)
        try fileManager.moveItem(at: directoryURL, to: relocatedDirectoryURL)
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        return PersistentDirectoryRecoveryResult(
            recoveryDirectoryURL: recoveryDirectoryURL,
            relocatedDirectoryURL: relocatedDirectoryURL
        )
    }

    private func existingStoreFiles(
        at directoryURL: URL,
        baseFileName: String,
        fileManager: FileManager
    ) throws -> [URL] {
        let directoryContents = try fileManager.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: nil
        )

        return directoryContents
            .filter { !$0.hasDirectoryPath }
            .filter { $0.lastPathComponent == baseFileName || $0.lastPathComponent.hasPrefix("\(baseFileName)-") }
            .sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
    }

    private func timestampToken(now: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter.string(from: now)
    }
}
