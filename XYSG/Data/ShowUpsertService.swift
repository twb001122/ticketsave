import Foundation
import SwiftData
import XYSGCore

struct ShowUpsertService {
    let coverRepository = CoverAssetRepository()

    func save(
        draft: ComposerDraft,
        editing showRecord: ShowRecord?,
        in context: ModelContext
    ) throws -> ShowRecord {
        let now = Date()
        let performers = try resolvePerformers(from: draft.selectedPerformers.map(\.id), in: context, now: now)
        let brand = try resolveBrand(id: draft.selectedBrandID, in: context, now: now)
        let venue = try resolveVenue(id: draft.selectedVenueID, in: context, now: now)

        let coverPath = try persistCoverIfNeeded(draft: draft, existingPath: showRecord?.coverStoragePath)
        let show = showRecord ?? ShowRecord(
            title: draft.storedTitle,
            createdAt: now,
            updatedAt: now
        )

        show.title = draft.storedTitle
        show.coverStoragePath = coverPath ?? showRecord?.coverStoragePath
        show.date = draft.date
        show.venue = venue
        show.brand = brand
        show.performers = performers
        show.format = draft.format
        show.myRole = draft.myRole
        show.showType = draft.showType
        show.notes = draft.notes
        show.tags = []
        show.updatedAt = now
        show.status = ShowStatus.published

        if showRecord == nil {
            context.insert(show)
        }

        try context.save()
        return show
    }

    private func persistCoverIfNeeded(draft: ComposerDraft, existingPath: String?) throws -> String? {
        guard let coverData = draft.coverData else {
            return existingPath
        }

        return try coverRepository.persistImageData(
            coverData,
            replacing: existingPath,
            fileExtension: draft.coverFileExtension
        )
    }

    private func resolvePerformers(
        from performerIDs: [UUID],
        in context: ModelContext,
        now: Date
    ) throws -> [Performer] {
        guard !performerIDs.isEmpty else { return [] }

        let descriptor = FetchDescriptor<Performer>()
        let allPerformers = try context.fetch(descriptor)
        var performersByID: [UUID: Performer] = [:]
        for performer in allPerformers {
            performersByID[performer.id] = performer
        }

        return performerIDs.compactMap { performerID in
            guard let performer = performersByID[performerID] else { return nil }
            performer.updatedAt = now
            return performer
        }
    }

    private func resolveBrand(
        id: UUID?,
        in context: ModelContext,
        now: Date
    ) throws -> ProductionBrand? {
        guard let id else { return nil }
        let descriptor = FetchDescriptor<ProductionBrand>()
        let brands = try context.fetch(descriptor)
        let brand = brands.first { $0.id == id }
        brand?.updatedAt = now
        return brand
    }

    private func resolveVenue(
        id: UUID?,
        in context: ModelContext,
        now: Date
    ) throws -> Venue? {
        guard let id else { return nil }
        let descriptor = FetchDescriptor<Venue>()
        let venues = try context.fetch(descriptor)
        let venue = venues.first { $0.id == id }
        venue?.updatedAt = now
        return venue
    }
}
