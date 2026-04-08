import Testing
@testable import XYSGCore

struct ThemePreferenceTests {
    @Test
    func exposesSystemLightAndDarkModes() {
        #expect(ThemePreference.allCases == [.system, .light, .dark])
    }

    @Test
    func providesStableTitlesAndIcons() {
        #expect(ThemePreference.system.title == "跟随系统")
        #expect(ThemePreference.system.systemImage == "circle.lefthalf.filled")
        #expect(ThemePreference.light.title == "亮色")
        #expect(ThemePreference.light.systemImage == "sun.max.fill")
        #expect(ThemePreference.dark.title == "暗色")
        #expect(ThemePreference.dark.systemImage == "moon.fill")
    }
}
