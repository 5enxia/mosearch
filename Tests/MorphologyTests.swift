import XCTest
import Mosearch

public class MorphologyTests: XCTestCase {
    func testConvertToKana() {
        let text = "こんにちは、世界！"
        let result = Morphology.convertToKana(text)
        XCTAssertEqual(result, "こんにちは､せかい!")
    }
    
    func testConvertToRomaji() {
        let text = "こんにちは、世界！"
        let result = Morphology.convertToRomaji(text)
        XCTAssertEqual(result, "kon'nichiha､sekai!")
    }
}