import SwiftUI

struct LocalCoverArtworkView: View {
    var data: Data?
    var storagePath: String?
    var title: String
    var subtitle: String?
    var showsTextOverlay: Bool

    nonisolated init(
        data: Data? = nil,
        storagePath: String? = nil,
        title: String,
        subtitle: String? = nil,
        showsTextOverlay: Bool = true
    ) {
        self.data = data
        self.storagePath = storagePath
        self.title = title
        self.subtitle = subtitle
        self.showsTextOverlay = showsTextOverlay
    }

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack(alignment: .bottomLeading) {
                if let image = resolvedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppTheme.sunOrange.opacity(0.9),
                                    AppTheme.amethyst.opacity(0.9),
                                    AppTheme.background,
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay {
                            Circle()
                                .fill(AppTheme.skyGlow.opacity(0.55))
                                .frame(width: 160, height: 160)
                                .blur(radius: 50)
                                .offset(x: 80, y: -100)
                        }
                }

                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.08), Color.black.opacity(0.68)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                if showsTextOverlay {
                    VStack(alignment: .leading, spacing: 8) {
                        Spacer()
                        Text(title.isEmpty ? "Untitled Show" : title)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.white)
                            .lineLimit(2)

                        if let subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.white.opacity(0.8))
                                .lineLimit(2)
                        }
                    }
                    .padding(20)
                }
            }
            .frame(width: size.width, height: size.height)
            .clipped()
        }
    }

    private var resolvedImage: UIImage? {
        CoverArtworkVisualProvider().image(data: data, storagePath: storagePath)
    }
}
