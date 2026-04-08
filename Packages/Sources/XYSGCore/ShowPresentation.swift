import Foundation

public enum ShowPresentation {
    public struct CardMetadata: Sendable, Hashable {
        public let primaryLine: String
        public let secondaryLine: String

        public init(primaryLine: String, secondaryLine: String) {
            self.primaryLine = primaryLine
            self.secondaryLine = secondaryLine
        }
    }

    public static let untitledShowName = "未命名演出"
    public static let pendingDateLabel = "待定时间"
    public static let pendingVenueLabel = "地点待补充"
    private static let cardDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    private static let cardTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    public static func storedTitle(from rawTitle: String) -> String {
        let trimmed = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? untitledShowName : trimmed
    }

    public static func compactCardDateTime(from date: Date) -> String {
        "\(cardDateFormatter.string(from: date).uppercased()) · \(cardTimeFormatter.string(from: date))"
    }

    public static func cardMetadata(date: Date?, formatDisplayName: String) -> CardMetadata {
        CardMetadata(
            primaryLine: date.map(compactCardDateTime(from:)) ?? pendingDateLabel,
            secondaryLine: formatDisplayName
        )
    }
}
