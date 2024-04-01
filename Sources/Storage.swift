public protocol Storage {
    func countDocuments() -> Result<Int, Error> // ドキュメント数を返す
    func addDocument(_ doc: Document) -> Result<DocumentID, Error> // ドキュメントを追加し、IDを返す
    func getDocuments(_ docIds: [DocumentID]) -> Result<[Document], Error> // 複数IDから複数ドキュメントを返す
    func addToken(_ token: Token) -> Result<TokenID, Error> // トークンを挿入する。挿入したドキュメントのIDを返す
    func getTokenByTerm(_ term: String) -> Result<Token?, Error> // 語句からトークンを取得する
    func getTokenByTerms(_ terms: [String]) -> Result<[Token], Error> // 語句からトークンを取得する
    func getInvertedIndexByTokenIDs(_ tokenIds: [TokenID]) -> Result<InvertedIndex, Error> // トークンIDの配列を受け取り、転置インデックスを返す
    func upsertInvertedIndex(_ invertedIndex: InvertedIndex) -> Result<Void, Error>// 転置リストを更新する             
}

public struct MockStorage: Storage {
    // TODO: あとで実装
    public func countDocuments() -> Result<Int, Error> {
        return .success(0)
    }

    // TODO: あとで実装
    public func addDocument(_ doc: Document) -> Result<DocumentID, Error> {
        return .success(0)
    }

    // TODO: あとで実装
    public func getDocuments(_ docs: [DocumentID]) -> Result<[Document], Error> {
        return .success([])
    }

    // TODO: あとで実装
    public func addToken(_ token: Token) -> Result<TokenID, Error> {
        return .success(0)
    }

    // TODO: あとで実装
    public func getInvertedIndexByTokenIDs(_ tokenIds: [TokenID]) -> Result<InvertedIndex, Error> {
        let invertedIndex: InvertedIndex = [:]
        return .success(invertedIndex)
    }
    
    // TODO: あとで実装
    public func upsertInvertedIndex(_ invertedIndex: InvertedIndex) -> Result<Void, Error> {
        return .success(())
    }

    // TODO: あとで実装
    public func getTokenByTerm(_ term: String) -> Result<Token?, Error> {
        return .success(Token(id: 0, term: term))
    }

    // TODO: あとで実装
    public func getTokenByTerms(_ terms: [String]) -> Result<[Token], Error> {
        return .success(terms.map { Token(id: 0, term: $0) })
    }
}