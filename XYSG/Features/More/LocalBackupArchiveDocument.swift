import SwiftUI
import UniformTypeIdentifiers
import XYSGCore

struct LocalBackupArchiveDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.zip] }

    var data: Data
    var manifest: BackupArchiveManifest?

    init(data: Data, manifest: BackupArchiveManifest? = nil) {
        self.data = data
        self.manifest = manifest
    }

    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents ?? Data()
        self.manifest = nil
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
