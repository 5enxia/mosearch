import XCTest
import Mosearch

public class AnalyzerTests: XCTestCase {
    func testAnalyzer() {
        let analyzer = Analyzer(
            charFilters: [],
            tokenizer: MorphologicalTokenizer(),
            tokenFilters: [StopwordTokenFilter()]
        )
        let stream = analyzer.analyze("Hello, world!")
        XCTAssertEqual(stream.tokens, [
            Token(id: 0, term: "Hello", kana: "へっろ"),
            Token(id: 0, term: "world", kana: "をるるで")
        ])
    }
}