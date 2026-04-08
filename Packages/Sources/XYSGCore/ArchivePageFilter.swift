import Foundation

public struct ArchiveQueryFilters: Sendable, Hashable {
    public var selectedFormat: ShowFormat?
    public var selectedBrandID: UUID?

    public init(selectedFormat: ShowFormat?, selectedBrandID: UUID?) {
        self.selectedFormat = selectedFormat
        self.selectedBrandID = selectedBrandID
    }
}

public struct ArchivePageRecord: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let updatedAt: Date
    public let format: ShowFormat
    public let brandID: UUID?

    public init(id: UUID, updatedAt: Date, format: ShowFormat, brandID: UUID?) {
        self.id = id
        self.updatedAt = updatedAt
        self.format = format
        self.brandID = brandID
    }
}

public enum ArchivePageFilter {
    public static func pageIDs(
        from records: [ArchivePageRecord],
        filters: ArchiveQueryFilters,
        offset: Int,
        limit: Int
    ) -> [UUID] {
        guard limit > 0 else { return [] }

        return records
            .filter { record in
                let formatMatches = filters.selectedFormat.map { record.format == $0 } ?? true
                let brandMatches = filters.selectedBrandID.map { record.brandID == $0 } ?? true
                return formatMatches && brandMatches
            }
            .dropFirst(offset)
            .prefix(limit)
            .map(\.id)
    }
}
