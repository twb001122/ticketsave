import SwiftUI
import UIKit
import XYSGCore

enum AppTheme {
    static let background = Color(themeLight: 0xF6F0E8, dark: 0x0D0E12)
    static let surfaceLow = Color(themeLight: 0xFFF9F3, dark: 0x151821)
    static let surfaceHigh = Color(themeLight: 0xF1E6DA, dark: 0x1B1E28)
    static let surfaceBright = Color(themeLight: 0xD8B8A0, dark: 0xFFFFFF)
    static let textPrimary = Color(themeLight: 0x251D19, dark: 0xFFFFFF)
    static let textSecondary = Color(themeLight: 0x74685F, dark: 0xFFFFFF, alphaDark: 0.68)
    static let onAccentText = Color(themeLight: 0x241B17, dark: 0x241B17)

    static let sunOrange = Color(themeLight: 0xDE7C53, dark: 0xFF9069)
    static let emberOrange = Color(themeLight: 0xE39A53, dark: 0xFFB36E)
    static let amethyst = Color(themeLight: 0xB77BD6, dark: 0xEDA3FF)
    static let berryGlow = Color(themeLight: 0xC565AA, dark: 0xFF7BD2)
    static let mintGlow = Color(themeLight: 0x42A48B, dark: 0x6FF0C7)
    static let skyGlow = Color(themeLight: 0x4F9AC2, dark: 0x7ED7FF)
    static let fogGlow = Color(themeLight: 0x8B7C72, dark: 0xFFFFFF, alphaDark: 0.72)

    static let glassStroke = Color(themeLight: 0xFFFFFF, alphaLight: 0.7, dark: 0xFFFFFF, alphaDark: 0.12)
    static let glassSpecular = Color(themeLight: 0xFFFFFF, alphaLight: 0.46, dark: 0xFFFFFF, alphaDark: 0.22)
    static let glassFillHighlight = Color(themeLight: 0xFFFFFF, alphaLight: 0.12, dark: 0xFFFFFF, alphaDark: 0.02)
    static let elevationShadow = Color(themeLight: 0x8C684D, alphaLight: 0.12, dark: 0x000000, alphaDark: 0.24)
    static let glowShadow = Color(themeLight: 0xD07B56, alphaLight: 0.14, dark: 0xFF9069, alphaDark: 0.08)
    static let cardBackdrop = Color(themeLight: 0xFFF7F0, alphaLight: 0.88, dark: 0xFFFFFF, alphaDark: 0.16)

    static let heroGradient = LinearGradient(
        colors: [sunOrange, emberOrange, amethyst],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [
            Color(themeLight: 0xFFF9F4, dark: 0x090A0F),
            Color(themeLight: 0xF6EFE6, dark: 0x0D0E12),
            Color(themeLight: 0xEDE1D3, dark: 0x14111A),
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
            Color(themeLight: 0x7FD6BE, dark: 0xA6FFE1)
        case .sky:
            Color(themeLight: 0x7EBFDF, dark: 0xB2E7FF)
        case .fog:
            Color(themeLight: 0xAA9C92, alphaLight: 0.58, dark: 0xFFFFFF, alphaDark: 0.48)
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

    init(
        themeLight lightHex: UInt,
        alphaLight: Double = 1,
        dark darkHex: UInt,
        alphaDark: Double = 1
    ) {
        self.init(
            uiColor: UIColor { traits in
                let useDark = traits.userInterfaceStyle == .dark
                return UIColor(
                    hex: useDark ? darkHex : lightHex,
                    alpha: useDark ? alphaDark : alphaLight
                )
            }
        )
    }
}

private extension UIColor {
    convenience init(hex: UInt, alpha: Double = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}
