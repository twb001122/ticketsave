import Foundation

public struct ArchivePaginationState: Sendable, Hashable {
    public let pageSize: Int
    public private(set) var loadedCount: Int
    public private(set) var hasMorePages: Bool

    public init(pageSize: Int = 20, loadedCount: Int = 0, hasMorePages: Bool = true) {
        self.pageSize = pageSize
        self.loadedCount = loadedCount
        self.hasMorePages = hasMorePages
    }

    public var nextFetchOffset: Int {
        loadedCount
    }

    public mutating func registerLoaded(itemCount: Int) {
        loadedCount += itemCount
        hasMorePages = itemCount == pageSize
    }

    public mutating func reset() {
        loadedCount = 0
        hasMorePages = true
    }
}
