import SwiftUI

struct StatPill: View {
    let title: String
    let value: String
    var accent: Color = AppTheme.sunOrange

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .tracking(1.4)
                .foregroundStyle(AppTheme.textSecondary)

            Text(value)
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassSurface(tint: accent.opacity(0.2), padding: 14, cornerRadius: 22)
    }
}
