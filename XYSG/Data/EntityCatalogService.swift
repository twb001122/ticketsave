import Foundation
import SwiftData
import XYSGCore

enum EntityCatalogError: LocalizedError {
    case emptyName(String)
    case duplicateBrand
    case duplicateVenue
    case entityInUse(String)

    var errorDescription: String? {
        switch self {
        case let .emptyName(subject):
            return "\(subject)名称不能为空。"
        case .duplicateBrand:
            return "已经存在同名厂牌了。"
        case .duplicateVenue:
            return "已经存在同名同城场地了。"
        case let .entityInUse(subject):
            return "\(subject)仍被演出引用，暂时不能删除。"
        }
    }
}

struct EntityCatalogService {
    func createPerformer(name: String, stageName: String, in context: ModelContext) throws -> Performer {
        let cleanName = try cleanedName(name, label: "演员")
        let now = Date()
        let performer = Performer(
            displayName: cleanName,
            normalizedKey: EntityLookupKey.performer(cleanName),
            stageName: cleanedOptional(stageName),
            createdAt: now,
            updatedAt: now
        )
        context.insert(performer)
        try context.save()
        return performer
    }

    func updatePerformer(_ performer: Performer, name: String, stageName: String, in context: ModelContext) throws {
        let cleanName = try cleanedName(name, label: "演员")
        performer.displayName = cleanName
        performer.normalizedKey = EntityLookupKey.performer(cleanName)
        performer.stageName = cleanedOptional(stageName)
        performer.updatedAt = .now
        try context.save()
    }

    func deletePerformer(_ performer: Performer, in context: ModelContext) throws {
        guard performer.shows.isEmpty else {
            throw EntityCatalogError.entityInUse("演员")
        }
        context.delete(performer)
        try context.save()
    }

    func createBrand(name: String, cityName: String, in context: ModelContext) throws -> ProductionBrand {
        let cleanName = try cleanedName(name, label: "厂牌")
        let normalizedKey = EntityLookupKey.brand(cleanName)
        try ensureUniqueBrand(normalizedKey: normalizedKey, excluding: nil, in: context)

        let now = Date()
        let brand = ProductionBrand(
            displayName: cleanName,
            normalizedKey: normalizedKey,
            cityName: cleanedOptional(cityName),
            createdAt: now,
            updatedAt: now
        )
        context.insert(brand)
        try context.save()
        return brand
    }

    func updateBrand(_ brand: ProductionBrand, name: String, cityName: String, in context: ModelContext) throws {
        let cleanName = try cleanedName(name, label: "厂牌")
        let normalizedKey = EntityLookupKey.brand(cleanName)
        try ensureUniqueBrand(normalizedKey: normalizedKey, excluding: brand.id, in: context)

        brand.displayName = cleanName
        brand.normalizedKey = normalizedKey
        brand.cityName = cleanedOptional(cityName)
        brand.updatedAt = .now
        try context.save()
    }

    func deleteBrand(_ brand: ProductionBrand, in context: ModelContext) throws {
        guard brand.shows.isEmpty else {
            throw EntityCatalogError.entityInUse("厂牌")
        }
        context.delete(brand)
        try context.save()
    }

    func createVenue(
        name: String,
        cityName: String,
        addressLine: String,
        district: String,
        in context: ModelContext
    ) throws -> Venue {
        let cleanName = try cleanedName(name, label: "场地")
        let cleanCity = cleanedOptional(cityName)
        let lookupKey = EntityLookupKey.venue(name: cleanName, city: cleanCity)
        try ensureUniqueVenue(lookupKey: lookupKey, excluding: nil, in: context)

        let now = Date()
        let venue = Venue(
            displayName: cleanName,
            normalizedKey: EntityLookupKey.normalizedValue(for: cleanName),
            lookupKey: lookupKey,
            addressLine: cleanedOptional(addressLine),
            district: cleanedOptional(district),
            cityName: cleanCity,
            createdAt: now,
            updatedAt: now
        )
        context.insert(venue)
        try context.save()
        return venue
    }

    func updateVenue(
        _ venue: Venue,
        name: String,
        cityName: String,
        addressLine: String,
        district: String,
        in context: ModelContext
    ) throws {
        let cleanName = try cleanedName(name, label: "场地")
        let cleanCity = cleanedOptional(cityName)
        let lookupKey = EntityLookupKey.venue(name: cleanName, city: cleanCity)
        try ensureUniqueVenue(lookupKey: lookupKey, excluding: venue.id, in: context)

        venue.displayName = cleanName
        venue.normalizedKey = EntityLookupKey.normalizedValue(for: cleanName)
        venue.lookupKey = lookupKey
        venue.cityName = cleanCity
        venue.addressLine = cleanedOptional(addressLine)
        venue.district = cleanedOptional(district)
        venue.updatedAt = .now
        try context.save()
    }

    func deleteVenue(_ venue: Venue, in context: ModelContext) throws {
        guard venue.shows.isEmpty else {
            throw EntityCatalogError.entityInUse("场地")
        }
        context.delete(venue)
        try context.save()
    }

    private func cleanedName(_ value: String, label: String) throws -> String {
        let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else {
            throw EntityCatalogError.emptyName(label)
        }
        return cleaned
    }

    private func cleanedOptional(_ value: String) -> String? {
        let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? nil : cleaned
    }

    private func ensureUniqueBrand(normalizedKey: String, excluding id: UUID?, in context: ModelContext) throws {
        let brands = try context.fetch(FetchDescriptor<ProductionBrand>())
        if brands.contains(where: { $0.normalizedKey == normalizedKey && $0.id != id }) {
            throw EntityCatalogError.duplicateBrand
        }
    }

    private func ensureUniqueVenue(lookupKey: String, excluding id: UUID?, in context: ModelContext) throws {
        let venues = try context.fetch(FetchDescriptor<Venue>())
        if venues.contains(where: { $0.lookupKey == lookupKey && $0.id != id }) {
            throw EntityCatalogError.duplicateVenue
        }
    }
}
