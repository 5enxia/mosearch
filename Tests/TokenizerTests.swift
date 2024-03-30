import XCTest
import Mosearch

public class TokenizerTests: XCTestCase {
    func testMorphologicalTokenizer() {
        let tokenizer = MorphologicalTokenizer()
        let stream = tokenizer.tokenize("こんにちは、世界")
        XCTAssertEqual(stream.tokens, [
            Token(id: 0, term: "こんにちは", kana: "こんにちは"),
            Token(id: 0, term: "世界", kana: "せかい")
        ])
    }

    func testNgramTokenizer() {
        let tokenizer = NgramTokenizer(2)
        let stream = tokenizer.tokenize("こんにちは、世界")
        XCTAssertEqual(stream.tokens, [
            Token(id: 0, term: "こん", kana: ""),
            Token(id: 0, term: "んに", kana: ""),
            Token(id: 0, term: "にち", kana: ""),
            Token(id: 0, term: "ちは", kana: ""),
            Token(id: 0, term: "は、", kana: ""),
            Token(id: 0, term: "、世", kana: ""),
            Token(id: 0, term: "世界", kana: ""),
        ])
    }
}