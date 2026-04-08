import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit
import XYSGCore

struct CoverArtworkVisualProvider {
    private let repository = CoverAssetRepository()
    nonisolated(unsafe) private static let imageCache = NSCache<NSString, UIImage>()
    nonisolated(unsafe) private static let paletteCache = NSCache<NSString, PaletteBox>()
    private static let ciContext = CIContext(options: [.cacheIntermediates: false])

    func image(data: Data?, storagePath: String?) -> UIImage? {
        if let data, let image = UIImage(data: data) {
            return image.normalizedForDisplay
        }

        guard
            let storagePath,
            let url = repository.url(for: storagePath)
        else {
            return nil
        }

        let cacheKey = NSString(string: storagePath)
        if let cached = Self.imageCache.object(forKey: cacheKey) {
            return cached
        }

        guard let image = UIImage(contentsOfFile: url.path)?.normalizedForDisplay else {
            return nil
        }

        Self.imageCache.setObject(image, forKey: cacheKey)
        return image
    }

    func palette(data: Data?, storagePath: String?) -> DynamicGlassPalette? {
        if let storagePath {
            let cacheKey = NSString(string: storagePath)
            if let cached = Self.paletteCache.object(forKey: cacheKey) {
                return cached.palette
            }

            guard let image = image(data: data, storagePath: storagePath) else {
                return nil
            }

            let palette = makePalette(from: image)
            if let palette {
                Self.paletteCache.setObject(PaletteBox(palette: palette), forKey: cacheKey)
            }
            return palette
        }

        guard let image = image(data: data, storagePath: nil) else {
            return nil
        }
        return makePalette(from: image)
    }

    private func makePalette(from image: UIImage) -> DynamicGlassPalette? {
        guard let ciImage = CIImage(image: image) else { return nil }

        let extent = ciImage.extent.integral
        guard !extent.isEmpty else { return nil }

        let upperCandidates = sampledColors(
            in: [
                normalizedRect(x: 0.08, y: 0.58, width: 0.28, height: 0.22),
                normalizedRect(x: 0.34, y: 0.62, width: 0.32, height: 0.20),
                normalizedRect(x: 0.64, y: 0.56, width: 0.24, height: 0.24),
            ],
            of: ciImage,
            extent: extent
        )
        let lowerCandidates = sampledColors(
            in: [
                normalizedRect(x: 0.08, y: 0.16, width: 0.30, height: 0.22),
                normalizedRect(x: 0.38, y: 0.12, width: 0.28, height: 0.24),
                normalizedRect(x: 0.66, y: 0.18, width: 0.20, height: 0.20),
            ],
            of: ciImage,
            extent: extent
        )

        guard let primary = mostVibrant(from: upperCandidates) ?? averageColor(in: extent, of: ciImage) else {
            return nil
        }

        let secondary = mostVibrant(from: lowerCandidates) ?? averageColor(in: extent, of: ciImage)
        return DynamicGlassPalette.make(primary: primary, secondary: secondary)
    }

    private func sampledColors(
        in normalizedRects: [CGRect],
        of image: CIImage,
        extent: CGRect
    ) -> [RGBColorSample] {
        normalizedRects.compactMap { rect in
            averageColor(in: denormalize(rect, within: extent), of: image)
        }
    }

    private func normalizedRect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }

    private func denormalize(_ rect: CGRect, within extent: CGRect) -> CGRect {
        CGRect(
            x: extent.minX + extent.width * rect.minX,
            y: extent.minY + extent.height * rect.minY,
            width: extent.width * rect.width,
            height: extent.height * rect.height
        )
    }

    private func mostVibrant(from colors: [RGBColorSample]) -> RGBColorSample? {
        colors.max { lhs, rhs in
            chromaScore(lhs) < chromaScore(rhs)
        }
    }

    private func chromaScore(_ color: RGBColorSample) -> Double {
        let maxChannel = max(color.red, color.green, color.blue)
        let minChannel = min(color.red, color.green, color.blue)
        let spread = maxChannel - minChannel
        let brightness = (color.red + color.green + color.blue) / 3
        return spread * 1.25 + brightness * 0.12
    }

    private func averageColor(in rect: CGRect, of image: CIImage) -> RGBColorSample? {
        let clampedRect = rect.intersection(image.extent)
        guard !clampedRect.isEmpty else { return nil }

        let filter = CIFilter.areaAverage()
        filter.inputImage = image
        filter.extent = clampedRect

        guard let output = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        Self.ciContext.render(
            output,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )

        return RGBColorSample(
            red: Double(bitmap[0]) / 255,
            green: Double(bitmap[1]) / 255,
            blue: Double(bitmap[2]) / 255
        )
    }
}

private final class PaletteBox: NSObject {
    let palette: DynamicGlassPalette

    init(palette: DynamicGlassPalette) {
        self.palette = palette
    }
}

extension UIImage {
    var normalizedForDisplay: UIImage {
        guard imageOrientation != .up else { return self }

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        format.opaque = false

        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
