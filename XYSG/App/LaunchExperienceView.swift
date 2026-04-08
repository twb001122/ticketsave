import SwiftUI

struct LaunchExperienceView: View {
    @State private var glowPulse = false
    @State private var cardLift = false

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            Circle()
                .fill(AppTheme.sunOrange.opacity(0.22))
                .frame(width: 260, height: 260)
                .blur(radius: glowPulse ? 26 : 50)
                .offset(x: -80, y: -140)

            Circle()
                .fill(AppTheme.skyGlow.opacity(0.22))
                .frame(width: 220, height: 220)
                .blur(radius: glowPulse ? 28 : 56)
                .offset(x: 110, y: -60)

            VStack(spacing: 28) {
                ZStack {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 220, height: 300)
                        .overlay {
                            RoundedRectangle(cornerRadius: 34, style: .continuous)
                                .strokeBorder(AppTheme.glassStroke)
                        }
                        .shadow(color: AppTheme.glowShadow.opacity(0.9), radius: 26, y: 16)

                    VStack(alignment: .leading, spacing: 14) {
                        Capsule()
                            .fill(AppTheme.heroGradient)
                            .frame(width: 86, height: 10)

                        Spacer()

                        Text("XYSG")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text("你的脱口秀票根档案馆")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding(24)
                }
                .rotationEffect(.degrees(cardLift ? -2 : 3))
                .scaleEffect(cardLift ? 1 : 0.92)

                Text("Lights up.")
                    .font(.headline.weight(.medium))
                    .foregroundStyle(AppTheme.textSecondary)
                    .tracking(1.8)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.9, dampingFraction: 0.78)) {
                cardLift = true
            }
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}
