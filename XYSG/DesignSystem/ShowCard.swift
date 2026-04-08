import SwiftUI
import XYSGCore

struct ShowCard: View {
    let show: ShowRecord
    let namespace: Namespace.ID
    private let visualProvider = CoverArtworkVisualProvider()

    var body: some View {
        let palette = visualProvider.palette(data: nil, storagePath: show.coverStoragePath)
        let accent = show.format.accentToken
        let metadata = ShowPresentation.cardMetadata(
            date: show.date,
            formatDisplayName: show.format.displayName
        )

        VStack(spacing: 0) {
            coverSection(palette: palette)

            infoPanel(
                accent: accent,
                metadata: metadata,
                palette: palette
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12))
        }
        .background {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(AppTheme.surfaceBright.opacity(0.16))
                .blur(radius: 18)
        }
        .shadow(color: Color.black.opacity(0.24), radius: 26, y: 18)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func coverSection(palette: DynamicGlassPalette?) -> some View {
        ZStack(alignment: .bottom) {
            LocalCoverArtworkView(
                storagePath: show.coverStoragePath,
                title: show.displayTitle,
                subtitle: show.brand?.displayName ?? show.venueDisplay,
                showsTextOverlay: false
            )
            .frame(maxWidth: .infinity)
            .frame(height: 186)
            .matchedTransitionSource(id: show.id, in: namespace)

            LinearGradient(
                colors: [
                    .clear,
                    Color.black.opacity(0.04),
                    palette?.bottomTint.swiftUIColor.opacity(0.22) ?? Color.black.opacity(0.16),
                ],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 56)
        }
    }

    private func infoPanel(
        accent: ShowFormatAccentToken,
        metadata: ShowPresentation.CardMetadata,
        palette: DynamicGlassPalette?
    ) -> some View {
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(show.displayTitle)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(metadata.primaryLine)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }

            HStack(alignment: .center, spacing: 12) {
                Text(show.venueDisplay.isEmpty ? ShowPresentation.pendingVenueLabel : show.venueDisplay)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                formatBadge(title: metadata.secondaryLine, accent: accent)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(panelBackground(for: palette))
    }

    private func panelBackground(for palette: DynamicGlassPalette?) -> some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(.regularMaterial)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: gradientColors(for: palette),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(0.34)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.28),
                            palette?.topHighlight.amplifiedSwiftUIColor(extraOpacity: 0.01) ?? Color.white.opacity(0.08),
                            Color.clear,
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 1.2)

            Circle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 88, height: 88)
                .blur(radius: 16)
                .offset(x: 72, y: -10)
        }
        .compositingGroup()
        .clipped()
    }

    @ViewBuilder
    private func formatBadge(title: String, accent: ShowFormatAccentToken) -> some View {
        Text(title)
            .font(.caption.weight(.bold))
            .foregroundStyle(accent.primaryColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                accent.primaryColor.opacity(0.20),
                                accent.secondaryColor.opacity(0.10),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .overlay {
                Capsule(style: .continuous)
                    .strokeBorder(accent.primaryColor.opacity(0.30))
            }
    }

    private func gradientColors(for palette: DynamicGlassPalette?) -> [Color] {
        guard let palette else {
            return [
                Color.white.opacity(0.10),
                Color.white.opacity(0.04),
                Color.black.opacity(0.02),
            ]
        }

        return [
            palette.topHighlight.amplifiedSwiftUIColor(extraOpacity: 0.01),
            palette.midTint.amplifiedSwiftUIColor(extraOpacity: 0.02),
            palette.bottomTint.amplifiedSwiftUIColor(extraOpacity: 0.03),
        ]
    }
}

private extension GlassTintStop {
    var swiftUIColor: Color {
        Color(
            red: red,
            green: green,
            blue: blue
        )
        .opacity(opacity)
    }

    func amplifiedSwiftUIColor(extraOpacity: Double) -> Color {
        Color(
            red: red,
            green: green,
            blue: blue
        )
        .opacity(min(opacity + extraOpacity, 0.9))
    }
}
