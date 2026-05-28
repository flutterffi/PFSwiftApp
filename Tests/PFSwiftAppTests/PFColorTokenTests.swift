@testable import PFSwiftApp
import XCTest

final class PFColorTokenTests: XCTestCase {
    func testRGBNormalizesValues() {
        let token = PFColorToken.rgb(red: 51, green: 102, blue: 255, opacity: 0.5)

        XCTAssertEqual(token.red, 51.0 / 255.0, accuracy: 0.0001)
        XCTAssertEqual(token.green, 102.0 / 255.0, accuracy: 0.0001)
        XCTAssertEqual(token.blue, 1, accuracy: 0.0001)
        XCTAssertEqual(token.opacity, 0.5, accuracy: 0.0001)
    }

    func testRGBClampsOutOfRangeValues() {
        let token = PFColorToken.rgb(red: -1, green: 256, blue: 128)

        XCTAssertEqual(token.red, 0, accuracy: 0.0001)
        XCTAssertEqual(token.green, 1, accuracy: 0.0001)
        XCTAssertEqual(token.blue, 128.0 / 255.0, accuracy: 0.0001)
    }

    func testHexParsesSixDigitValue() throws {
        let token = try XCTUnwrap(PFColorToken.hex("#3366FF"))

        XCTAssertEqual(token.red, 51.0 / 255.0, accuracy: 0.0001)
        XCTAssertEqual(token.green, 102.0 / 255.0, accuracy: 0.0001)
        XCTAssertEqual(token.blue, 1, accuracy: 0.0001)
        XCTAssertEqual(token.opacity, 1, accuracy: 0.0001)
    }

    func testHexParsesEightDigitValueWithAlpha() throws {
        let token = try XCTUnwrap(PFColorToken.hex("3366FF80"))

        XCTAssertEqual(token.red, 51.0 / 255.0, accuracy: 0.0001)
        XCTAssertEqual(token.green, 102.0 / 255.0, accuracy: 0.0001)
        XCTAssertEqual(token.blue, 1, accuracy: 0.0001)
        XCTAssertEqual(token.opacity, 128.0 / 255.0, accuracy: 0.0001)
    }

    func testHexRejectsInvalidValues() {
        XCTAssertNil(PFColorToken.hex("336"))
        XCTAssertNil(PFColorToken.hex("GG66FF"))
        XCTAssertNil(PFColorToken.hex(""))
    }
}
