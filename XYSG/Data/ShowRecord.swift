import Foundation
import SwiftData
import XYSGCore

@Model
final class ShowRecord {
    var id: UUID
    var title: String
    var coverStoragePath: String?
    var date: Date?
    @Relationship(deleteRule: .nullify, inverse: \Venue.shows) var venue: Venue?
    @Relationship(deleteRule: .nullify, inverse: \ProductionBrand.shows) var brand: ProductionBrand?
    @Relationship(deleteRule: .nullify, inverse: \Performer.shows) var performers: [Performer]
    var format: ShowFormat
    var myRole: ShowRole
    var showType: ShowType
    var notes: String
    var tags: [String]
    var createdAt: Date
    var updatedAt: Date
    var status: ShowStatus
    var achievementFlags: [String]

    init(
        id: UUID = UUID(),
        title: String,
        coverStoragePath: String? = nil,
        date: Date? = nil,
        venue: Venue? = nil,
        brand: ProductionBrand? = nil,
        performers: [Performer] = [],
        format: ShowFormat = .standup,
        myRole: ShowRole = .performer,
        showType: ShowType = .showcase,
        notes: String = "",
        tags: [String] = [],
        createdAt: Date = .now,
        updatedAt: Date = .now,
        status: ShowStatus = .published,
        achievementFlags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.coverStoragePath = coverStoragePath
        self.date = date
        self.venue = venue
        self.brand = brand
        self.performers = performers
        self.format = format
        self.myRole = myRole
        self.showType = showType
        self.notes = notes
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.status = status
        self.achievementFlags = achievementFlags
    }
}

extension ShowRecord {
    var displayTitle: String {
        ShowPresentation.storedTitle(from: title)
    }

    var lineupDisplay: String {
        let names = performers.map(\.displayName)
        return names.isEmpty ? "待补充阵容" : names.joined(separator: " · ")
    }

    var venueDisplay: String {
        [venue?.displayName, venue?.cityName]
            .compactMap { value in
                guard let value, !value.isEmpty else { return nil }
                return value
            }
            .joined(separator: " · ")
    }

    var dateDisplay: String {
        guard let date else { return ShowPresentation.pendingDateLabel }
        return AppTheme.detailFormatter.string(from: date)
    }
}
