public protocol TokenFilter {
    func filter(_ stream: TokenStream) -> TokenStream
}

// lowercase: 小文字に変換する
public struct LowercaseTokenFilter: TokenFilter {
    public init() {}

    public func filter(_ stream: TokenStream) -> TokenStream {
        var stream = stream
        stream.tokens = stream.tokens.map { token in
            var token = token
            token.term = token.term.lowercased()
            return token
        }
        return stream
    }
}

// stopword: 除外する単語
public struct StopwordTokenFilter: TokenFilter {
    public init() {}

    private let stopwords: Set<String> = [
        "a", "an", "and", "are", "as", "at", "be", "by", "for", "from", "has", "he", "in", "is", "it", "its", "of", "on", "that", "the", "to", "was", "were", "will", "with"
    ]
    
    public func filter(_ stream: TokenStream) -> TokenStream {
        var stream = stream
        stream.tokens = stream.tokens.filter { token in
            !stopwords.contains(token.term)
        }
        return stream
    }
}

// romajiReading: ローマ字読みにする
public struct RomajiReadingformTokenFilter: TokenFilter {
    public init() {}

    public func filter(_ stream: TokenStream) -> TokenStream {
        var stream = stream
        stream.tokens = stream.tokens.map { token in
            var token = token
            token.term = Morphology.convertToRomaji(token.term)
            return token
        }
        return stream
    }
}