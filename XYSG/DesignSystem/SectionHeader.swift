import SwiftUI

struct SectionHeader: View {
    let eyebrow: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(eyebrow.uppercased())
                .font(.caption2.weight(.semibold))
                .tracking(1.8)
                .foregroundStyle(AppTheme.textSecondary)

            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
        }
    }
}
