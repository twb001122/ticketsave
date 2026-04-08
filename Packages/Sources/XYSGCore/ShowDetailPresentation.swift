import Foundation

public enum ShowDetailPresentation {
    public struct HighlightContent: Sendable, Hashable {
        public let primary: String
        public let secondary: String

        public init(primary: String, secondary: String) {
            self.primary = primary
            self.secondary = secondary
        }
    }

    public struct DetailRow: Sendable, Hashable {
        public let title: String
        public let value: String
        public let systemImage: String

        public init(title: String, value: String, systemImage: String) {
            self.title = title
            self.value = value
            self.systemImage = systemImage
        }
    }

    public static let pendingDateTimeLabel = "待定时间"
    public static let pendingVenueLabel = "剧场待补充"
    public static let pendingLocationLabel = "城市地点待补充"
    public static let pendingBrandLabel = "厂牌待补充"

    private static let detailDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    private static let compactDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    private static let compactTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static let updatedAtFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    public static func dateTimeValue(for date: Date?) -> String {
        guard let date else { return pendingDateTimeLabel }
        return detailDateFormatter.string(from: date)
    }

    public static func venueValue(venueName: String?) -> String {
        cleaned(venueName) ?? pendingVenueLabel
    }

    public static func brandValue(brandName: String?) -> String {
        cleaned(brandName) ?? pendingBrandLabel
    }

    public static func dateHighlightContent(for date: Date?) -> HighlightContent {
        guard let date else {
            return HighlightContent(primary: "待定日期", secondary: "待定时间")
        }
        return HighlightContent(
            primary: compactDateFormatter.string(from: date),
            secondary: compactTimeFormatter.string(from: date)
        )
    }

    public static func venueHighlightContent(venueName: String?, district: String?, cityName: String?) -> HighlightContent {
        HighlightContent(
            primary: venueValue(venueName: venueName),
            secondary: cleaned(district) ?? cleaned(cityName) ?? "地点待补充"
        )
    }

    public static func locationHighlightContent(cityName: String?, district: String?) -> HighlightContent {
        HighlightContent(
            primary: cleaned(district) ?? cleaned(cityName) ?? "地点待补充",
            secondary: cleaned(district) != nil ? (cleaned(cityName) ?? "城市待补充") : "区域待补充"
        )
    }

    public static func locationSummary(cityName: String?, district: String?) -> String {
        let joined = [cleaned(cityName), cleaned(district)]
            .compactMap { $0 }
            .joined(separator: " · ")
        return joined.isEmpty ? pendingLocationLabel : joined
    }

    public static func additionalRows(
        formatDisplayName: String,
        roleDisplayName: String,
        showTypeDisplayName: String,
        brandName: String?,
        updatedAt: Date
    ) -> [DetailRow] {
        [
            DetailRow(title: "内容形式", value: formatDisplayName, systemImage: "theatermasks.fill"),
            DetailRow(title: "我的角色", value: roleDisplayName, systemImage: "person.crop.circle.badge.checkmark"),
            DetailRow(title: "演出属性", value: showTypeDisplayName, systemImage: "sparkles"),
            DetailRow(title: "厂牌", value: brandValue(brandName: brandName), systemImage: "ticket.fill"),
            DetailRow(title: "最后更新", value: updatedAtFormatter.string(from: updatedAt), systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
        ]
    }

    private static func cleaned(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return nil
        }
        return trimmed
    }
}
