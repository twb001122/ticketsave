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
                        .foregroundStyle(isSelected ? Color.black.opacity(0.8) : AppTheme.textSecondary)
                }
            }
            .foregroundStyle(isSelected ? Color.black.opacity(0.85) : AppTheme.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(isSelected ? AnyShapeStyle(AppTheme.heroGradient) : AnyShapeStyle(.ultraThinMaterial))
                    .overlay {
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(isSelected ? 0.04 : 0.03))
                    }
            )
        }
        .buttonStyle(.plain)
    }
}
