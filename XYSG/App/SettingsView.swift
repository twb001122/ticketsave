import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()

                EntityManagementView()
                    .padding(20)
            }
            .navigationTitle("Settings")
        }
    }
}
