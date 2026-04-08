import SwiftUI
import XYSGCore

enum AppAppearance {
    static let storageKey = "themePreference"
}

extension ThemePreference {
    var preferredColorScheme: ColorScheme? {
        switch self {
        case .system:
            nil
        case .light:
            .light
        case .dark:
            .dark
        }
    }
}
