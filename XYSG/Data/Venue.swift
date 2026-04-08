import Foundation
import SwiftData

@Model
final class Venue {
    var id: UUID
    var displayName: String
    var normalizedKey: String
    @Attribute(.unique) var lookupKey: String
    var addressLine: String?
    var district: String?
    var cityName: String?
    var shows: [ShowRecord]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        displayName: String,
        normalizedKey: String,
        lookupKey: String,
        addressLine: String? = nil,
        district: String? = nil,
        cityName: String? = nil,
        shows: [ShowRecord] = [],
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.displayName = displayName
        self.normalizedKey = normalizedKey
        self.lookupKey = lookupKey
        self.addressLine = addressLine
        self.district = district
        self.cityName = cityName
        self.shows = shows
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Venue: Identifiable {}
