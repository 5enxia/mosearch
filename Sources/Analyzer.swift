public struct Analyzer {
    private let charFilters: [CharFilter]
    private let tokenizer: Tokenizer
    private let tokenFilters: [TokenFilter]

    public init(charFilters: [CharFilter], tokenizer: Tokenizer, tokenFilters: [TokenFilter]) {
        self.charFilters = charFilters
        self.tokenizer = tokenizer
        self.tokenFilters = tokenFilters
    }

    public func analyze(_ s: String) -> TokenStream {
        var s = s
        // 文字列変換を実行する
        for charFilter in charFilters {
            s = charFilter.filter(s)
        }
        var tokenStream = tokenizer.tokenize(s)
        for tokenFilter in tokenFilters {
            tokenStream = tokenFilter.filter(tokenStream)
        }

        return tokenStream
    }
}

