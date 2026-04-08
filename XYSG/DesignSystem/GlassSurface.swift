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
                                        AppTheme.glassFillHighlight,
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(AppTheme.glassStroke)
                    }
                    .shadow(color: AppTheme.glowShadow, radius: 24, y: 8)
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
