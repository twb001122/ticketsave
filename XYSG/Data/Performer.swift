import Foundation
import SwiftData

@Model
final class Performer {
    var id: UUID
    var displayName: String
    var normalizedKey: String
    var stageName: String?
    var avatarStoragePath: String?
    @Relationship(deleteRule: .nullify, inverse: \ProductionBrand.performers) var brands: [ProductionBrand]
    var venues: [Venue]
    var shows: [ShowRecord]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        displayName: String,
        normalizedKey: String,
        stageName: String? = nil,
        avatarStoragePath: String? = nil,
        brands: [ProductionBrand] = [],
        venues: [Venue] = [],
        shows: [ShowRecord] = [],
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.displayName = displayName
        self.normalizedKey = normalizedKey
        self.stageName = stageName
        self.avatarStoragePath = avatarStoragePath
        self.brands = brands
        self.venues = venues
        self.shows = shows
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Performer: Identifiable {}
