import SwiftUI

struct GlowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(AppTheme.onAccentText.opacity(0.88))
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                Capsule(style: .continuous)
                    .fill(AppTheme.heroGradient)
                    .shadow(color: AppTheme.sunOrange.opacity(0.24), radius: 20, y: 10)
                    .scaleEffect(configuration.isPressed ? 0.98 : 1)
                    .animation(.spring(response: 0.26, dampingFraction: 0.78), value: configuration.isPressed)
            )
    }
}
