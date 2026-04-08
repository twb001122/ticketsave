public enum ThemePreference: String, CaseIterable, Identifiable, Sendable {
    case system
    case light
    case dark

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .system:
            "跟随系统"
        case .light:
            "亮色"
        case .dark:
            "暗色"
        }
    }

    public var subtitle: String {
        switch self {
        case .system:
            "自动跟随 iPhone 外观"
        case .light:
            "白天版的玻璃档案馆"
        case .dark:
            "当前这套夜场视觉"
        }
    }

    public var systemImage: String {
        switch self {
        case .system:
            "circle.lefthalf.filled"
        case .light:
            "sun.max.fill"
        case .dark:
            "moon.fill"
        }
    }
}
