import XCTest
import Mosearch

public class TokenFilterTests: XCTestCase {
    func testLowercaseTokenFilter() {
        let filter = LowercaseTokenFilter()
        let stream = TokenStream(tokens: [Token(term: "Hello"), Token(term: "World")])
        let result = filter.filter(stream)
        XCTAssertEqual(result.tokens, [Token(term: "hello"), Token(term: "world")])
    }
    
    func testStopwordTokenFilter() {
        let filter = StopwordTokenFilter()
        let stream = TokenStream(tokens: [Token(term: "a"), Token(term: "the"), Token(term: "world")])
        let result = filter.filter(stream)
        XCTAssertEqual(result.tokens, [Token(term: "world")])
    }
    
    func testRomajiReadingformTokenFilter() {
        let filter = RomajiReadingformTokenFilter()
        let stream = TokenStream(tokens: [Token(term: "こんにちは"), Token(term: "世界")])
        let result = filter.filter(stream)
        XCTAssertEqual(result.tokens, [Token(term: "kon'nichiha"), Token(term: "sekai")])
    }
}