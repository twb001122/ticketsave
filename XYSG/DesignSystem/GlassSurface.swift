import SwiftUI

struct GlassSurface: ViewModifier {
    var tint: Color = AppTheme.surfaceBright
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 28

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        tint.opacity(0.35),
                                        Color.white.opacity(0.02),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .shadow(color: AppTheme.sunOrange.opacity(0.08), radius: 24, y: 8)
            )
    }
}

extension View {
    func glassSurface(
        tint: Color = AppTheme.surfaceBright,
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 28
    ) -> some View {
        modifier(GlassSurface(tint: tint, padding: padding, cornerRadius: cornerRadius))
    }
}
