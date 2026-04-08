import SwiftUI
import XYSGCore

struct SettingsView: View {
    @AppStorage(AppAppearance.storageKey) private var themePreferenceRawValue = ThemePreference.system.rawValue

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        hero
                        appearanceSection
                        destinationsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 120)
                }
            }
            .navigationTitle("Settings")
            .navigationDestination(for: SettingsDestination.self) { destination in
                switch destination {
                case .entityManagement:
                    EntityManagementScreen()
                case .localBackup:
                    MoreView()
                }
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SETTINGS")
                .font(.caption.weight(.semibold))
                .tracking(2)
                .foregroundStyle(AppTheme.textSecondary)

            Text("设置中心。")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Text("实体维护和本地备份现在都收在这里，后面继续加更多设置也会更自然。")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private var destinationsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(eyebrow: "Modules", title: "设置入口")

            ForEach(SettingsDestination.allCases) { destination in
                NavigationLink(value: destination) {
                    SettingsEntryCard(destination: destination)
                }
                .buttonStyle(.plain)
                .simultaneousGesture(
                    TapGesture().onEnded {
                        Haptics.selection()
                    }
                )
            }
        }
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(eyebrow: "Appearance", title: "外观")

            HStack(spacing: 12) {
                ForEach(ThemePreference.allCases) { preference in
                    Button {
                        themePreferenceRawValue = preference.rawValue
                        Haptics.selection()
                    } label: {
                        ThemePreferenceCard(
                            preference: preference,
                            isSelected: themePreference == preference
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(themePreference.subtitle)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private var themePreference: ThemePreference {
        ThemePreference(rawValue: themePreferenceRawValue) ?? .system
    }
}

private struct ThemePreferenceCard: View {
    let preference: ThemePreference
    let isSelected: Bool

    private var accent: Color {
        switch preference {
        case .system:
            AppTheme.amethyst
        case .light:
            AppTheme.emberOrange
        case .dark:
            AppTheme.skyGlow
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(isSelected ? accent.opacity(0.24) : AppTheme.surfaceBright.opacity(0.12))

                Image(systemName: preference.systemImage)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(isSelected ? accent : AppTheme.textSecondary)
            }
            .frame(width: 44, height: 44)

            Text(preference.title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(isSelected ? accent.opacity(0.34) : AppTheme.glassStroke.opacity(0.55))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    isSelected ? accent.opacity(0.18) : AppTheme.glassFillHighlight.opacity(0.4),
                                    Color.clear,
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
        )
        .shadow(color: isSelected ? accent.opacity(0.12) : AppTheme.glowShadow.opacity(0.04), radius: 14, y: 8)
    }
}

private struct SettingsEntryCard: View {
    let destination: SettingsDestination

    private var accent: Color {
        switch destination {
        case .entityManagement:
            AppTheme.sunOrange
        case .localBackup:
            AppTheme.skyGlow
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        accent.opacity(0.26),
                                        AppTheme.glassFillHighlight.opacity(0.7),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }

                Image(systemName: destination.systemImage)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(accent)
            }
            .frame(width: 58, height: 58)

            VStack(alignment: .leading, spacing: 6) {
                Text(destination.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(destination.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 10)

            Image(systemName: "chevron.right")
                .font(.headline.weight(.semibold))
                .foregroundStyle(AppTheme.textSecondary.opacity(0.9))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .glassSurface(tint: accent.opacity(0.14), padding: 0, cornerRadius: 30)
    }
}

private struct EntityManagementScreen: View {
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            EntityManagementView()
                .padding(20)
        }
        .navigationTitle(SettingsDestination.entityManagement.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
