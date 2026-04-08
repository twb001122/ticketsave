import Foundation
import SwiftData

@Model
final class ProductionBrand {
    var id: UUID
    var displayName: String
    @Attribute(.unique) var normalizedKey: String
    var cityName: String?
    var accentColorHex: String?
    var performers: [Performer]
    @Relationship(deleteRule: .nullify, inverse: \Venue.brands) var venues: [Venue]
    var shows: [ShowRecord]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        displayName: String,
        normalizedKey: String,
        cityName: String? = nil,
        accentColorHex: String? = nil,
        performers: [Performer] = [],
        venues: [Venue] = [],
        shows: [ShowRecord] = [],
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.displayName = displayName
        self.normalizedKey = normalizedKey
        self.cityName = cityName
        self.accentColorHex = accentColorHex
        self.performers = performers
        self.venues = venues
        self.shows = shows
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension ProductionBrand: Identifiable {}
