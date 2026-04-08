import Foundation

public struct CoverImageStore: Sendable {
    public enum StoreError: Error {
        case invalidFileExtension
    }

    public let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    @discardableResult
    public func importImageData(_ data: Data, fileExtension: String) throws -> String {
        let relativePath = makeRelativePath(fileExtension: fileExtension)
        let destinationURL = baseURL.appendingPathComponent(relativePath)

        try ensureBaseDirectoryExists()
        try data.write(to: destinationURL, options: .atomic)
        return relativePath
    }

    @discardableResult
    public func replaceImageData(
        _ data: Data,
        replacing oldRelativePath: String?,
        fileExtension: String
    ) throws -> String {
        let newRelativePath = try importImageData(data, fileExtension: fileExtension)

        if let oldRelativePath {
            try removeIfExists(relativePath: oldRelativePath)
        }

        return newRelativePath
    }

    public func pruneUnusedAssets(referencedPaths: some Sequence<String>) throws {
        try ensureBaseDirectoryExists()

        let referenced = Set(referencedPaths.filter { !$0.isEmpty })
        let fileURLs = try FileManager.default.contentsOfDirectory(
            at: baseURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )

        for fileURL in fileURLs {
            let relativePath = fileURL.lastPathComponent
            if !referenced.contains(relativePath) {
                try FileManager.default.removeItem(at: fileURL)
            }
        }
    }

    private func makeRelativePath(fileExtension: String) -> String {
        let sanitizedExtension = fileExtension
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if sanitizedExtension.isEmpty {
            return UUID().uuidString.lowercased()
        }

        return "\(UUID().uuidString.lowercased()).\(sanitizedExtension)"
    }

    private func ensureBaseDirectoryExists() throws {
        try FileManager.default.createDirectory(
            at: baseURL,
            withIntermediateDirectories: true
        )
    }

    private func removeIfExists(relativePath: String) throws {
        let fileURL = baseURL.appendingPathComponent(relativePath)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
}
