import Foundation

public struct ShowStatsRecord: Sendable, Hashable {
    public let date: Date?
    public let format: ShowFormat
    public let role: ShowRole
    public let showType: ShowType
    public let brandID: UUID?

    public init(
        date: Date?,
        format: ShowFormat,
        role: ShowRole,
        showType: ShowType,
        brandID: UUID?
    ) {
        self.date = date
        self.format = format
        self.role = role
        self.showType = showType
        self.brandID = brandID
    }
}

public struct ArchiveStatsSummary: Sendable, Hashable {
    public let totalShows: Int
    public let latestShowDate: Date?
    public let formatCounts: [ShowFormat: Int]
    public let roleCounts: [ShowRole: Int]
    public let typeCounts: [ShowType: Int]
    public let brandCounts: [UUID: Int]

    public init(
        totalShows: Int,
        latestShowDate: Date?,
        formatCounts: [ShowFormat: Int],
        roleCounts: [ShowRole: Int],
        typeCounts: [ShowType: Int],
        brandCounts: [UUID: Int]
    ) {
        self.totalShows = totalShows
        self.latestShowDate = latestShowDate
        self.formatCounts = formatCounts
        self.roleCounts = roleCounts
        self.typeCounts = typeCounts
        self.brandCounts = brandCounts
    }
}

public enum ArchiveStatsSummaryCalculator {
    public static func makeSummary(from records: [ShowStatsRecord]) -> ArchiveStatsSummary {
        var formatCounts: [ShowFormat: Int] = [:]
        var roleCounts: [ShowRole: Int] = [:]
        var typeCounts: [ShowType: Int] = [:]
        var brandCounts: [UUID: Int] = [:]

        for record in records {
            formatCounts[record.format, default: 0] += 1
            roleCounts[record.role, default: 0] += 1
            typeCounts[record.showType, default: 0] += 1

            if let brandID = record.brandID {
                brandCounts[brandID, default: 0] += 1
            }
        }

        return ArchiveStatsSummary(
            totalShows: records.count,
            latestShowDate: records.compactMap(\.date).max(),
            formatCounts: formatCounts,
            roleCounts: roleCounts,
            typeCounts: typeCounts,
            brandCounts: brandCounts
        )
    }
}
