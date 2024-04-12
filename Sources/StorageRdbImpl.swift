import Foundation
import SQLite

public typealias Byte = UInt8

public struct EncodedInvertedIndex: Codable {
    let tokenId: TokenID
    // let postingList: [Byte]
    let postingList: String
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

    public func getInvertedIndexByTokenIDs(_ tokenIds: [TokenID]) -> Swift.Result<InvertedIndex, Error> {
        if tokenIds.isEmpty {
            return .success([:])
        }
        var encoded: [EncodedInvertedIndex] = []

        do {
            let invertedIndexes = Table("inverted_indexes")
            let tokenIdExp = Expression<Int>("token_id")
            let query = invertedIndexes.filter(tokenIds.contains(tokenIdExp))
            for row in try self.db.prepare(query) {
                let tokenId = TokenID(row[tokenIdExp])
                // let postingList = row[Expression<Blob>("posting_list")]
                let postingList = row[Expression<String>("posting_list")]
                encoded.append(EncodedInvertedIndex(tokenId: tokenId, postingList: postingList))
            }
            let decoded = self.decode(encoded)
            switch decoded {
            case .success(let d):
                return .success(d)
            case .failure(let error):
                return .failure(error)
            }
        } catch(let error) {
            return .failure(error)
        }
    }
    
    public func upsertInvertedIndex(_ invertedIndex: InvertedIndex) -> Swift.Result<Void, Error> {
        let encode = self.encode(invertedIndex)
        switch encode {
        case .success(let e):
            do {
                let invertedIndexes = Table("inverted_indexes")
                let tokenIdExp = Expression<Int>("token_id")
                let postingListExp = Expression<String>("posting_list")
                for e in e {
                    let query = invertedIndexes.filter(tokenIdExp == Int(e.tokenId))
                    if try self.db.run(query.update(postingListExp <- e.postingList)) == 0 {
                        try self.db.run(invertedIndexes.insert(
                            tokenIdExp <- Int(e.tokenId),
                            postingListExp <- e.postingList
                        ))
                    }
                }
                return .success(())
            } catch(let error) {
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
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
                let encoder = JSONEncoder()
                do {
                    let data = try encoder.encode(p)
                    encodedInvertedIndex.append(EncodedInvertedIndex(tokenId: tokenId, postingList: data.base64EncodedString()))
                } catch {
                    return .failure(error)
                }
            }
        }
        return .success(encodedInvertedIndex)
    }

    private func decode(_ e: [EncodedInvertedIndex]) -> Swift.Result<InvertedIndex, Error> {
        var invertedIndex: InvertedIndex = [:]
        for e in e {
            let decoder = JSONDecoder()
            guard let data = Data(base64Encoded: e.postingList) else {
                let error = DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Failed to decode base64 string"))
                return .failure(error)
            }
            do {
                let postings = try decoder.decode(Postings.self, from: data)
                let pl = PostingList(postings: postings)
                // 差分から元の値に戻す
                var p: Postings? = pl.postings
                var beforeDocumentId: DocumentID = 0
                while p != nil {
                    p?.documentId += beforeDocumentId
                    beforeDocumentId = p!.documentId
                    p = p?.next
                }
                invertedIndex[e.tokenId] = pl
            } catch {
                return .failure(error)
            }
        }
        return .success(invertedIndex)
    }
}