public typealias TokenID = Int

public struct Token: Equatable {
    public init(id: TokenID = 0, term: String = "", kana: String = "") {
        self.id = id
        self.term = term
        self.kana = kana
    }

    var id: TokenID
    var term: String
    var kana: String
}

public struct TokenStream {
    public init(tokens: [Token] = []) {
        self.tokens = tokens
    }
    public var tokens: [Token]
    public func size() -> Int {
        return self.tokens.count
    }
}