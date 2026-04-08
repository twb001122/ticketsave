import XCTest
@testable import XYSGCore

final class ImageSizingTests: XCTestCase {
    func testScalesLandscapeImageUsingShortestSideLimit() {
        let target = ImageSizing.scaledSize(
            for: CGSize(width: 1600, height: 900),
            maxShortestSide: 540
        )

        XCTAssertEqual(target.width, 960)
        XCTAssertEqual(target.height, 540)
    }

    func testScalesPortraitImageUsingShortestSideLimit() {
        let target = ImageSizing.scaledSize(
            for: CGSize(width: 1080, height: 1920),
            maxShortestSide: 540
        )

        XCTAssertEqual(target.width, 540)
        XCTAssertEqual(target.height, 960)
    }

    func testDoesNotUpscaleSmallImages() {
        let target = ImageSizing.scaledSize(
            for: CGSize(width: 480, height: 320),
            maxShortestSide: 540
        )

        XCTAssertEqual(target.width, 480)
        XCTAssertEqual(target.height, 320)
    }
}
