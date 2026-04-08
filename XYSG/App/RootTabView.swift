import SwiftUI
import XYSGCore

struct RootTabView: View {
    let recoveryMessage: String?

    @AppStorage(AppAppearance.storageKey) private var themePreferenceRawValue = ThemePreference.system.rawValue
    @State private var selectedTab: RootTab = .archive
    @State private var showsLaunchOverlay = true
    @State private var activeRecoveryMessage: String?

    init(recoveryMessage: String? = nil) {
        self.recoveryMessage = recoveryMessage
    }

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                ArchiveView()
                    .tag(RootTab.archive)
                    .tabItem {
                        Label("Archive", systemImage: "square.stack.3d.up.fill")
                    }

                SettingsView()
                    .tag(RootTab.settings)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            }

            if showsLaunchOverlay {
                LaunchExperienceView()
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
                    .zIndex(2)
            }
        }
        .task {
            Haptics.prewarm()
            try? await Task.sleep(for: .milliseconds(1150))
            withAnimation(.easeInOut(duration: 0.45)) {
                showsLaunchOverlay = false
            }
            if activeRecoveryMessage == nil {
                activeRecoveryMessage = recoveryMessage
            }
        }
        .onChange(of: selectedTab) { _, _ in
            Haptics.selection()
        }
        .alert(
            "本地档案已恢复为新库",
            isPresented: Binding(
                get: { activeRecoveryMessage != nil },
                set: { if !$0 { activeRecoveryMessage = nil } }
            )
        ) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(activeRecoveryMessage ?? "")
        }
        .tint(AppTheme.sunOrange)
        .preferredColorScheme(themePreference.preferredColorScheme)
    }

    private var themePreference: ThemePreference {
        ThemePreference(rawValue: themePreferenceRawValue) ?? .system
    }
}

private enum RootTab {
    case archive
    case settings
}
