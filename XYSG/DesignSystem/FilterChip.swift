import SwiftUI

struct FilterChip: View {
    let title: String
    var isSelected: Bool
    var count: Int?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                if let count {
                    Text("\(count)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(isSelected ? AppTheme.onAccentText.opacity(0.8) : AppTheme.textSecondary)
                }
            }
            .foregroundStyle(isSelected ? AppTheme.onAccentText.opacity(0.85) : AppTheme.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(isSelected ? AnyShapeStyle(AppTheme.heroGradient) : AnyShapeStyle(.ultraThinMaterial))
                    .overlay {
                        Capsule(style: .continuous)
                            .fill(AppTheme.glassFillHighlight.opacity(isSelected ? 1 : 0.7))
                    }
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(AppTheme.glassStroke.opacity(isSelected ? 0.0 : 0.45))
                    }
            )
        }
        .buttonStyle(.plain)
    }
}
