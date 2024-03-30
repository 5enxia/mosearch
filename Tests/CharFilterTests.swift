import XCTest
import Mosearch

public class CharFilterTests: XCTestCase {
    func testMappingCharFilter() {
        let filter = MappingCharFilter(mapper: ["か": "ka", "き": "ki"])
        let result = filter.filter("かきくけこ")
        XCTAssertEqual(result, "kakiくけこ")
    }
}