import Foundation
import SwiftData

struct ShowRecordDeletionService {
    let coverRepository = CoverAssetRepository()

    func delete(_ show: ShowRecord, in context: ModelContext) throws {
        context.delete(show)
        try context.save()

        let referencedPaths = try context.fetch(FetchDescriptor<ShowRecord>())
            .compactMap(\.coverStoragePath)
        try coverRepository.pruneUnusedAssets(referencedPaths: referencedPaths)
    }
}
