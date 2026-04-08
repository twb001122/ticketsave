import Foundation
import SwiftData
import XYSGCore

struct BackupArchiveMapper {
    private let coverRepository = CoverAssetRepository()

    func makePayload(
        shows: [ShowRecord],
        performers: [Performer],
        brands: [ProductionBrand],
        venues: [Venue],
        appVersion: String
    ) throws -> BackupBundlePayload {
        let archive = BackupArchive(
            manifest: BackupArchiveManifest(
                exportedAt: .now,
                appVersion: appVersion,
                counts: BackupArchiveCounts(
                    shows: shows.count,
                    performers: performers.count,
                    brands: brands.count,
                    venues: venues.count
                )
            ),
            shows: shows.map(makeBackupShow),
            performers: performers.map(makeBackupPerformer),
            brands: brands.map(makeBackupBrand),
            venues: venues.map(makeBackupVenue)
        )

        let coverFiles = try shows
            .compactMap(\.coverStoragePath)
            .removingDuplicates()
            .map { relativePath in
                BackupAssetFile(
                    fileName: relativePath,
                    data: try coverRepository.data(for: relativePath)
                )
            }

        return BackupBundlePayload(archive: archive, coverFiles: coverFiles)
    }

    func restore(
        payload: BackupBundlePayload,
        in context: ModelContext
    ) throws {
        let shows = try context.fetch(FetchDescriptor<ShowRecord>())
        let performers = try context.fetch(FetchDescriptor<Performer>())
        let brands = try context.fetch(FetchDescriptor<ProductionBrand>())
        let venues = try context.fetch(FetchDescriptor<Venue>())

        for show in shows {
            context.delete(show)
        }
        try context.save()

        for performer in performers {
            context.delete(performer)
        }
        for brand in brands {
            context.delete(brand)
        }
        for venue in venues {
            context.delete(venue)
        }
        try context.save()

        try coverRepository.replaceAllAssets(with: payload.coverFiles)

        var performersByID: [UUID: Performer] = [:]
        var brandsByID: [UUID: ProductionBrand] = [:]
        var venuesByID: [UUID: Venue] = [:]

        for performerRecord in payload.archive.performers {
            let performer = Performer(
                id: performerRecord.id,
                displayName: performerRecord.displayName,
                normalizedKey: performerRecord.normalizedKey,
                stageName: performerRecord.stageName,
                avatarStoragePath: performerRecord.avatarFileName,
                createdAt: performerRecord.createdAt,
                updatedAt: performerRecord.updatedAt
            )
            performersByID[performer.id] = performer
            context.insert(performer)
        }

        for brandRecord in payload.archive.brands {
            let brand = ProductionBrand(
                id: brandRecord.id,
                displayName: brandRecord.displayName,
                normalizedKey: brandRecord.normalizedKey,
                cityName: brandRecord.cityName,
                accentColorHex: brandRecord.accentColorHex,
                createdAt: brandRecord.createdAt,
                updatedAt: brandRecord.updatedAt
            )
            brandsByID[brand.id] = brand
            context.insert(brand)
        }

        for venueRecord in payload.archive.venues {
            let venue = Venue(
                id: venueRecord.id,
                displayName: venueRecord.displayName,
                normalizedKey: venueRecord.normalizedKey,
                lookupKey: venueRecord.lookupKey,
                addressLine: venueRecord.addressLine,
                district: venueRecord.district,
                cityName: venueRecord.cityName,
                createdAt: venueRecord.createdAt,
                updatedAt: venueRecord.updatedAt
            )
            venuesByID[venue.id] = venue
            context.insert(venue)
        }

        for showRecord in payload.archive.shows {
            let show = ShowRecord(
                id: showRecord.id,
                title: showRecord.title,
                coverStoragePath: showRecord.coverFileName,
                date: showRecord.date,
                venue: showRecord.venueID.flatMap { venuesByID[$0] },
                brand: showRecord.brandID.flatMap { brandsByID[$0] },
                performers: showRecord.performerIDs.compactMap { performersByID[$0] },
                format: showRecord.format,
                myRole: showRecord.myRole,
                showType: showRecord.showType,
                notes: showRecord.notes,
                tags: showRecord.tags,
                createdAt: showRecord.createdAt,
                updatedAt: showRecord.updatedAt,
                status: showRecord.status,
                achievementFlags: showRecord.achievementFlags
            )
            context.insert(show)
        }

        try context.save()
    }

    private func makeBackupShow(from show: ShowRecord) -> BackupShowRecord {
        BackupShowRecord(
            id: show.id,
            title: show.title,
            coverFileName: show.coverStoragePath,
            date: show.date,
            venueID: show.venue?.id,
            brandID: show.brand?.id,
            performerIDs: show.performers.map(\.id),
            format: show.format,
            myRole: show.myRole,
            showType: show.showType,
            notes: show.notes,
            tags: show.tags,
            createdAt: show.createdAt,
            updatedAt: show.updatedAt,
            status: show.status,
            achievementFlags: show.achievementFlags
        )
    }

    private func makeBackupPerformer(from performer: Performer) -> BackupPerformerRecord {
        BackupPerformerRecord(
            id: performer.id,
            displayName: performer.displayName,
            normalizedKey: performer.normalizedKey,
            stageName: performer.stageName,
            avatarFileName: performer.avatarStoragePath,
            createdAt: performer.createdAt,
            updatedAt: performer.updatedAt
        )
    }

    private func makeBackupBrand(from brand: ProductionBrand) -> BackupBrandRecord {
        BackupBrandRecord(
            id: brand.id,
            displayName: brand.displayName,
            normalizedKey: brand.normalizedKey,
            cityName: brand.cityName,
            accentColorHex: brand.accentColorHex,
            createdAt: brand.createdAt,
            updatedAt: brand.updatedAt
        )
    }

    private func makeBackupVenue(from venue: Venue) -> BackupVenueRecord {
        BackupVenueRecord(
            id: venue.id,
            displayName: venue.displayName,
            normalizedKey: venue.normalizedKey,
            lookupKey: venue.lookupKey,
            addressLine: venue.addressLine,
            district: venue.district,
            cityName: venue.cityName,
            createdAt: venue.createdAt,
            updatedAt: venue.updatedAt
        )
    }
}

private extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var seen: Set<Element> = []
        return filter { seen.insert($0).inserted }
    }
}
