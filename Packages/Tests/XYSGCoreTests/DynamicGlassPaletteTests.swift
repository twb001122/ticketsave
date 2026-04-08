import Testing
@testable import XYSGCore

struct DynamicGlassPaletteTests {
    @Test
    func softensVividPrimaryColorIntoTranslucentTint() {
        let palette = DynamicGlassPalette.make(
            primary: RGBColorSample(red: 0.96, green: 0.26, blue: 0.18),
            secondary: nil
        )

        #expect(palette.midTint.opacity == 0.5)
        #expect(palette.midTint.red > 0.88)
        #expect(palette.midTint.green < 0.4)
        #expect(palette.midTint.blue < 0.34)
        #expect(palette.topHighlight.opacity == 0.42)
        #expect(
            palette.topHighlight.red + palette.topHighlight.green + palette.topHighlight.blue >
                palette.midTint.red + palette.midTint.green + palette.midTint.blue
        )
    }

    @Test
    func blendsSecondaryColorIntoLowerEdgeTint() {
        let palette = DynamicGlassPalette.make(
            primary: RGBColorSample(red: 0.24, green: 0.52, blue: 0.92),
            secondary: RGBColorSample(red: 0.86, green: 0.38, blue: 0.64)
        )

        #expect(palette.bottomTint.opacity == 0.28)
        #expect(palette.bottomTint.red > 0.24)
        #expect(palette.bottomTint.blue > 0.52)
        #expect(palette.bottomTint.green > 0.32)
    }
}
