import Foundation
import UIKit
import XYSGCore

struct CoverAssetRepository {
    let store: CoverImageStore
    private let fileManager: FileManager
    private let maxShortestSide: CGFloat = 540

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        let applicationSupportURL = try? fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let baseURL = (applicationSupportURL ?? fileManager.temporaryDirectory)
            .appendingPathComponent("Covers", isDirectory: true)
        self.store = CoverImageStore(baseURL: baseURL)
    }

    func url(for relativePath: String?) -> URL? {
        guard let relativePath, !relativePath.isEmpty else { return nil }
        return store.baseURL.appendingPathComponent(relativePath)
    }

    func persistImageData(
        _ data: Data,
        replacing currentPath: String?,
        fileExtension: String
    ) throws -> String {
        let compressedData = compressedImageData(from: data)
        let preparedData = compressedData ?? data
        let normalizedExtension = compressedData == nil ? fileExtension : "jpg"
        return try store.replaceImageData(
            preparedData,
            replacing: currentPath,
            fileExtension: normalizedExtension
        )
    }

    func data(for relativePath: String) throws -> Data {
        try Data(contentsOf: store.baseURL.appendingPathComponent(relativePath))
    }

    func replaceAllAssets(with files: [BackupAssetFile]) throws {
        try removeAllAssets()
        try fileManager.createDirectory(at: store.baseURL, withIntermediateDirectories: true)

        for file in files {
            try file.data.write(
                to: store.baseURL.appendingPathComponent(file.fileName),
                options: .atomic
            )
        }
    }

    func removeAllAssets() throws {
        if fileManager.fileExists(atPath: store.baseURL.path) {
            try fileManager.removeItem(at: store.baseURL)
        }
        try fileManager.createDirectory(at: store.baseURL, withIntermediateDirectories: true)
    }

    func pruneUnusedAssets(referencedPaths: [String]) throws {
        try store.pruneUnusedAssets(referencedPaths: referencedPaths)
    }

    private func compressedImageData(from data: Data) -> Data? {
        guard let image = UIImage(data: data)?.normalizedForStorage else {
            return nil
        }

        let originalSize = image.size
        let targetSize = ImageSizing.scaledSize(
            for: originalSize,
            maxShortestSide: maxShortestSide
        )
        guard targetSize != .zero else { return nil }

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = false

        let rendered = UIGraphicsImageRenderer(size: targetSize, format: format).image { context in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: targetSize))
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        return rendered.jpegData(compressionQuality: 0.78)
    }
}

private extension UIImage {
    var normalizedForStorage: UIImage {
        guard imageOrientation != .up else { return self }

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = false

        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
