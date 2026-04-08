import Foundation

public enum BackupArchiveVersion {
    public static let currentSchemaVersion = 2
}

public struct BackupArchiveManifest: Codable, Sendable, Hashable {
    public let schemaVersion: Int
    public let exportedAt: Date
    public let appVersion: String
    public let counts: BackupArchiveCounts

    public init(
        schemaVersion: Int = BackupArchiveVersion.currentSchemaVersion,
        exportedAt: Date,
        appVersion: String,
        counts: BackupArchiveCounts
    ) {
        self.schemaVersion = schemaVersion
        self.exportedAt = exportedAt
        self.appVersion = appVersion
        self.counts = counts
    }
}

public struct BackupArchiveCounts: Codable, Sendable, Hashable {
    public let shows: Int
    public let performers: Int
    public let brands: Int
    public let venues: Int

    public init(shows: Int, performers: Int, brands: Int, venues: Int) {
        self.shows = shows
        self.performers = performers
        self.brands = brands
        self.venues = venues
    }
}

public struct BackupArchive: Codable, Sendable, Hashable {
    public let manifest: BackupArchiveManifest
    public let shows: [BackupShowRecord]
    public let performers: [BackupPerformerRecord]
    public let brands: [BackupBrandRecord]
    public let venues: [BackupVenueRecord]

    public init(
        manifest: BackupArchiveManifest,
        shows: [BackupShowRecord],
        performers: [BackupPerformerRecord],
        brands: [BackupBrandRecord],
        venues: [BackupVenueRecord]
    ) {
        self.manifest = manifest
        self.shows = shows
        self.performers = performers
        self.brands = brands
        self.venues = venues
    }
}

public struct BackupShowRecord: Codable, Sendable, Hashable {
    public let id: UUID
    public let title: String
    public let coverFileName: String?
    public let date: Date?
    public let venueID: UUID?
    public let brandID: UUID?
    public let performerIDs: [UUID]
    public let format: ShowFormat
    public let myRole: ShowRole
    public let showType: ShowType
    public let notes: String
    public let tags: [String]
    public let createdAt: Date
    public let updatedAt: Date
    public let status: ShowStatus
    public let achievementFlags: [String]

    public init(
        id: UUID,
        title: String,
        coverFileName: String?,
        date: Date?,
        venueID: UUID?,
        brandID: UUID?,
        performerIDs: [UUID],
        format: ShowFormat,
        myRole: ShowRole,
        showType: ShowType,
        notes: String,
        tags: [String],
        createdAt: Date,
        updatedAt: Date,
        status: ShowStatus,
        achievementFlags: [String]
    ) {
        self.id = id
        self.title = title
        self.coverFileName = coverFileName
        self.date = date
        self.venueID = venueID
        self.brandID = brandID
        self.performerIDs = performerIDs
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

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let now = Date(timeIntervalSince1970: 0)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        coverFileName = try container.decodeIfPresent(String.self, forKey: .coverFileName)
        date = try container.decodeIfPresent(Date.self, forKey: .date)
        venueID = try container.decodeIfPresent(UUID.self, forKey: .venueID)
        brandID = try container.decodeIfPresent(UUID.self, forKey: .brandID)
        performerIDs = try container.decodeIfPresent([UUID].self, forKey: .performerIDs) ?? []
        format = try container.decodeIfPresent(ShowFormat.self, forKey: .format) ?? .other
        myRole = try container.decodeIfPresent(ShowRole.self, forKey: .myRole) ?? .performer
        showType = try container.decodeIfPresent(ShowType.self, forKey: .showType) ?? .showcase
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? now
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? createdAt
        status = try container.decodeIfPresent(ShowStatus.self, forKey: .status) ?? .published
        achievementFlags = try container.decodeIfPresent([String].self, forKey: .achievementFlags) ?? []
    }
}

public struct BackupPerformerRecord: Codable, Sendable, Hashable {
    public let id: UUID
    public let displayName: String
    public let normalizedKey: String
    public let stageName: String?
    public let avatarFileName: String?
    public let brandIDs: [UUID]
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: UUID,
        displayName: String,
        normalizedKey: String,
        stageName: String?,
        avatarFileName: String?,
        brandIDs: [UUID],
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.displayName = displayName
        self.normalizedKey = normalizedKey
        self.stageName = stageName
        self.avatarFileName = avatarFileName
        self.brandIDs = brandIDs
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let now = Date(timeIntervalSince1970: 0)
        id = try container.decode(UUID.self, forKey: .id)
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName) ?? ""
        normalizedKey = try container.decodeIfPresent(String.self, forKey: .normalizedKey) ?? ""
        stageName = try container.decodeIfPresent(String.self, forKey: .stageName)
        avatarFileName = try container.decodeIfPresent(String.self, forKey: .avatarFileName)
        brandIDs = try container.decodeIfPresent([UUID].self, forKey: .brandIDs) ?? []
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? now
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? createdAt
    }
}

public struct BackupBrandRecord: Codable, Sendable, Hashable {
    public let id: UUID
    public let displayName: String
    public let normalizedKey: String
    public let cityName: String?
    public let accentColorHex: String?
    public let performerIDs: [UUID]
    public let venueIDs: [UUID]
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: UUID,
        displayName: String,
        normalizedKey: String,
        cityName: String?,
        accentColorHex: String?,
        performerIDs: [UUID],
        venueIDs: [UUID],
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.displayName = displayName
        self.normalizedKey = normalizedKey
        self.cityName = cityName
        self.accentColorHex = accentColorHex
        self.performerIDs = performerIDs
        self.venueIDs = venueIDs
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let now = Date(timeIntervalSince1970: 0)
        id = try container.decode(UUID.self, forKey: .id)
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName) ?? ""
        normalizedKey = try container.decodeIfPresent(String.self, forKey: .normalizedKey) ?? ""
        cityName = try container.decodeIfPresent(String.self, forKey: .cityName)
        accentColorHex = try container.decodeIfPresent(String.self, forKey: .accentColorHex)
        performerIDs = try container.decodeIfPresent([UUID].self, forKey: .performerIDs) ?? []
        venueIDs = try container.decodeIfPresent([UUID].self, forKey: .venueIDs) ?? []
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? now
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? createdAt
    }
}

public struct BackupVenueRecord: Codable, Sendable, Hashable {
    public let id: UUID
    public let displayName: String
    public let normalizedKey: String
    public let lookupKey: String
    public let addressLine: String?
    public let district: String?
    public let cityName: String?
    public let performerIDs: [UUID]
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: UUID,
        displayName: String,
        normalizedKey: String,
        lookupKey: String,
        addressLine: String?,
        district: String?,
        cityName: String?,
        performerIDs: [UUID],
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.displayName = displayName
        self.normalizedKey = normalizedKey
        self.lookupKey = lookupKey
        self.addressLine = addressLine
        self.district = district
        self.cityName = cityName
        self.performerIDs = performerIDs
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let now = Date(timeIntervalSince1970: 0)
        id = try container.decode(UUID.self, forKey: .id)
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName) ?? ""
        normalizedKey = try container.decodeIfPresent(String.self, forKey: .normalizedKey) ?? ""
        lookupKey = try container.decodeIfPresent(String.self, forKey: .lookupKey) ?? normalizedKey
        addressLine = try container.decodeIfPresent(String.self, forKey: .addressLine)
        district = try container.decodeIfPresent(String.self, forKey: .district)
        cityName = try container.decodeIfPresent(String.self, forKey: .cityName)
        performerIDs = try container.decodeIfPresent([UUID].self, forKey: .performerIDs) ?? []
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? now
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? createdAt
    }
}
