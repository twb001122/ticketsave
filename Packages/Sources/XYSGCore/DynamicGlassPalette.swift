import Foundation

public struct RGBColorSample: Sendable, Hashable {
    public let red: Double
    public let green: Double
    public let blue: Double

    public init(red: Double, green: Double, blue: Double) {
        self.red = red.clampedToUnitInterval
        self.green = green.clampedToUnitInterval
        self.blue = blue.clampedToUnitInterval
    }
}

public struct GlassTintStop: Sendable, Hashable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let opacity: Double

    public init(red: Double, green: Double, blue: Double, opacity: Double) {
        self.red = red.clampedToUnitInterval
        self.green = green.clampedToUnitInterval
        self.blue = blue.clampedToUnitInterval
        self.opacity = opacity.clampedToUnitInterval
    }
}

public struct DynamicGlassPalette: Sendable, Hashable {
    public let topHighlight: GlassTintStop
    public let midTint: GlassTintStop
    public let bottomTint: GlassTintStop

    public static func make(
        primary: RGBColorSample,
        secondary: RGBColorSample?
    ) -> DynamicGlassPalette {
        let softenedPrimary = primary
            .mixed(with: .white, amount: 0.08)
            .energized(minimumSpread: 0.14)
        let softenedSecondary = (secondary ?? primary)
            .mixed(with: .white, amount: 0.04)
            .energized(minimumSpread: 0.10)

        return DynamicGlassPalette(
            topHighlight: GlassTintStop(
                red: softenedPrimary.red * 0.58 + 0.42,
                green: softenedPrimary.green * 0.58 + 0.42,
                blue: softenedPrimary.blue * 0.58 + 0.42,
                opacity: 0.42
            ),
            midTint: GlassTintStop(
                red: softenedPrimary.red,
                green: softenedPrimary.green,
                blue: softenedPrimary.blue,
                opacity: 0.5
            ),
            bottomTint: GlassTintStop(
                red: softenedSecondary.red * 0.72 + softenedPrimary.red * 0.28,
                green: softenedSecondary.green * 0.72 + softenedPrimary.green * 0.28,
                blue: softenedSecondary.blue * 0.72 + softenedPrimary.blue * 0.28,
                opacity: 0.28
            )
        )
    }
}

private extension RGBColorSample {
    static let white = RGBColorSample(red: 1, green: 1, blue: 1)

    func mixed(with other: RGBColorSample, amount: Double) -> RGBColorSample {
        let t = amount.clampedToUnitInterval
        return RGBColorSample(
            red: red * (1 - t) + other.red * t,
            green: green * (1 - t) + other.green * t,
            blue: blue * (1 - t) + other.blue * t
        )
    }

    func energized(minimumSpread: Double) -> RGBColorSample {
        let average = (red + green + blue) / 3
        let spread = minimumSpread.clampedToUnitInterval

        func shift(_ channel: Double) -> Double {
            let delta = channel - average
            let direction = delta == 0 ? 0 : (delta > 0 ? 1.0 : -1.0)
            let magnitude = max(abs(delta) * 1.18, spread * 0.5)
            return (average + direction * magnitude).clampedToUnitInterval
        }

        return RGBColorSample(
            red: shift(red),
            green: shift(green),
            blue: shift(blue)
        )
    }
}

private extension Double {
    var clampedToUnitInterval: Double {
        min(max(self, 0), 1)
    }
}
