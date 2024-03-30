
public protocol Tokenizer {
    func tokenize(_ s: String) -> TokenStream
}

// 形態素解析
public struct MorphologicalTokenizer: Tokenizer {
    public init() {}

    public func tokenize(_ s: String) -> TokenStream {
        let tokens = Morphology.tokenize(s)
        return TokenStream(tokens: tokens)
    }
}

// N-gram
public struct NgramTokenizer: Tokenizer {
    private let n: Int

    public init(_ n: Int = 2) {
        self.n = n
    }

    public func tokenize(_ s: String) -> TokenStream {
        let count = s.count + 1 - self.n
        let tokens = (0..<count).map { i in
            Token(id: 0, term: String(s[s.index(s.startIndex, offsetBy: i)..<s.index(s.startIndex, offsetBy: i + self.n)]), kana: "")
        }
        return TokenStream(tokens: tokens)
    }
}