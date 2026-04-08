import CoreGraphics

public enum ImageSizing {
    public static func scaledSize(
        for originalSize: CGSize,
        maxShortestSide: CGFloat
    ) -> CGSize {
        let width = originalSize.width
        let height = originalSize.height

        guard width > 0, height > 0, maxShortestSide > 0 else {
            return .zero
        }

        let shortestSide = min(width, height)
        let scaleFactor = min(1, maxShortestSide / shortestSide)

        return CGSize(
            width: max(1, (width * scaleFactor).rounded(.toNearestOrAwayFromZero)),
            height: max(1, (height * scaleFactor).rounded(.toNearestOrAwayFromZero))
        )
    }
}
