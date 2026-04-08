import Foundation
import SwiftData

@Model
final class ProductionBrand {
    var id: UUID
    var displayName: String
    @Attribute(.unique) var normalizedKey: String
    var cityName: String?
    var accentColorHex: String?
    var shows: [ShowRecord]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        displayName: String,
        normalizedKey: String,
        cityName: String? = nil,
        accentColorHex: String? = nil,
        shows: [ShowRecord] = [],
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.displayName = displayName
        self.normalizedKey = normalizedKey
        self.cityName = cityName
        self.accentColorHex = accentColorHex
        self.shows = shows
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension ProductionBrand: Identifiable {}
