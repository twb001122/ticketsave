import SwiftUI
import XYSGCore

enum AppTheme {
    static let background = Color(hex: 0x0D0E12)
    static let surfaceLow = Color(hex: 0x151821)
    static let surfaceHigh = Color(hex: 0x1B1E28)
    static let surfaceBright = Color.white.opacity(0.12)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.68)
    static let sunOrange = Color(hex: 0xFF9069)
    static let emberOrange = Color(hex: 0xFFB36E)
    static let amethyst = Color(hex: 0xEDA3FF)
    static let berryGlow = Color(hex: 0xFF7BD2)
    static let mintGlow = Color(hex: 0x6FF0C7)
    static let skyGlow = Color(hex: 0x7ED7FF)
    static let fogGlow = Color.white.opacity(0.72)
    static let heroGradient = LinearGradient(
        colors: [sunOrange, emberOrange, amethyst],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(hex: 0x090A0F),
            Color(hex: 0x0D0E12),
            Color(hex: 0x14111A),
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static let detailFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

extension ShowFormatAccentToken {
    var primaryColor: Color {
        switch self {
        case .sun:
            AppTheme.sunOrange
        case .berry:
            AppTheme.berryGlow
        case .mint:
            AppTheme.mintGlow
        case .sky:
            AppTheme.skyGlow
        case .fog:
            AppTheme.fogGlow
        }
    }

    var secondaryColor: Color {
        switch self {
        case .sun:
            AppTheme.emberOrange
        case .berry:
            AppTheme.amethyst
        case .mint:
            Color(hex: 0xA6FFE1)
        case .sky:
            Color(hex: 0xB2E7FF)
        case .fog:
            Color.white.opacity(0.48)
        }
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}
