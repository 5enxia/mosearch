import SQLite

public struct StorageRdbImpl: Storage {
    public func getAllDocuments() -> Swift.Result<[Document], Error> {
        .success([])
    }

    // TODO: あとで実装
    public func countDocuments() -> Swift.Result<Int, Error> {
        return .success(0)
    }

    // TODO: あとで実装
    public func addDocument(_ doc: Document) -> Swift.Result<DocumentID, Error> {
        return .success(0)
    }

    // TODO: あとで実装
    public func getDocuments(_ docs: [DocumentID]) -> Swift.Result<[Document], Error> {
        return .success([])
    }

    // TODO: あとで実装
    public func addToken(_ token: Token) -> Swift.Result<TokenID, Error> {
        return .success(0)
    }

    // TODO: あとで実装
    public func getInvertedIndexByTokenIDs(_ tokenIds: [TokenID]) -> Swift.Result<InvertedIndex, Error> {
        let invertedIndex: InvertedIndex = [:]
        return .success(invertedIndex)
    }
    
    // TODO: あとで実装
    public func upsertInvertedIndex(_ invertedIndex: InvertedIndex) -> Swift.Result<Void, Error> {
        return .success(())
    }

    // TODO: あとで実装
    public func getTokenByTerm(_ term: String) -> Swift.Result<Token?, Error> {
        return .success(Token(id: 0, term: term))
    }

    // TODO: あとで実装
    public func getTokenByTerms(_ terms: [String]) -> Swift.Result<[Token], Error> {
        return .success(terms.map { Token(id: 0, term: $0) })
    }
}