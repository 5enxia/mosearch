import SQLite

public typealias Byte = UInt8

public struct EncodedInvertedIndex: Codable {
    let tokenId: TokenID
    let postingList: [Byte]
}

public struct StorageRdbImpl: Storage {
    private let db: Connection

    public init() {
        do {
            self.db = try Connection("./db/test.db")
        } catch {
            fatalError("Failed to open database: \(error)")
        }
    }

    public func getAllDocuments() -> Swift.Result<[Document], Error> {
        .success([])
    }

    // TODO: あとで実装
    public func countDocuments() -> Swift.Result<Int, Error> {
        return .success(0)
    }

    public func addDocument(_ doc: Document) -> Swift.Result<DocumentID, Error> {
        do {
            let documents = Table("documents")
            let body = Expression<String>("body")

            let rowid = try self.db.run(documents.insert(
                body <- doc.body
            ))
            return .success(DocumentID(rowid))
        } catch(let error) {
            return .failure(error)
        }
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
        if tokenIds.isEmpty {
            return .success([:])
        }
        var encode: [EncodedInvertedIndex] = []

        do {
            let invertedIndexes = Table("inverted_indexes")
            let tokenIdExp = Expression<Int>("token_id")
            let query = invertedIndexes.filter(tokenIds.contains(tokenIdExp))
            for row in try self.db.prepare(query) {
                let tokenId = TokenID(row[tokenIdExp])
                let postingList = row[Expression<Blob>("posting_list")]
            }
            return .success([:])
        } catch(let error) {
            return .failure(error)
        }
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

    private func encode(_ invertedIndex: InvertedIndex) -> Swift.Result<[EncodedInvertedIndex], Error> {
        var encodedInvertedIndex: [EncodedInvertedIndex] = []
        for (tokenId, postingList) in invertedIndex {
            var p: Postings? = postingList.postings
            // 差分を取る
            var beforeDocumentId: DocumentID = 0
            while p != nil {
                p?.documentId -= beforeDocumentId
                beforeDocumentId += p!.documentId
                p = p?.next
            } 
            if let p {
                encodedInvertedIndex.append(EncodedInvertedIndex(tokenId: tokenId, postingList: p.toBytes()))
            }
        }
        return .success(encodedInvertedIndex)
    }

    private func decode(_ e: [EncodedInvertedIndex]) -> Swift.Result<InvertedIndex, Error> {
        var invertedIndex: InvertedIndex = [:]
        for e in e {
            let postingList = PostingList.fromBytes(e.postingList)
            invertedIndex[e.tokenId] = postingList
        }
        return .success(invertedIndex)
    }
}