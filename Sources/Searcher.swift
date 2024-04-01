public protocol Searcher {
    func search() -> Result<[Document], Error>
    
    // util
    func tokenIds(_ tokens: [Token]) -> [TokenID]
    func notAllNil(_ postings: [Postings?]) -> Bool
    func isSameDocumentId(_ postings: [Postings?]) -> Bool
    func next(_ postings: [Postings?]) -> [Postings?]
    func minDoucmentIdIndex(_ postings: [Postings?]) -> Int
    func allNil(_ postings: [Postings?]) -> Bool
}

// デフォルト実装
extension Searcher {
    public func tokenIds(_ tokens: [Token]) -> [TokenID] {
        return tokens.map { $0.id }
    }

    // 全てのポスティングリストがnilでない
    public func notAllNil(_ postings: [Postings?]) -> Bool {
        for _postings in postings {
            if _postings == nil {
                return false
            }
        }
        return true
    }

    public func isSameDocumentId(_ postings: [Postings?]) -> Bool {
        return postings.map { $0?.documentId }.allSatisfy { $0 == postings[0]?.documentId }
    }

    public func next(_ postings: [Postings?]) -> [Postings?] {
        return postings.map { $0?.next }
    }

    public func minDoucmentIdIndex(_ postings: [Postings?]) -> Int {
        var min = Int.max
        var idx = -1
        for i in 0..<postings.count {
            if let posting = postings[i], Int(posting.documentId) < min {
                min = Int(posting.documentId)
                idx = i
            }
        }
        return idx
    }

    // 全てのポステイングリストがnil
    public func allNil(_ postings: [Postings?]) -> Bool {
        for _postings in postings {
            if _postings != nil {
                return false
            }
        }
        return true
    }
}

public enum Logic {
    case AND
    case OR
}

// AND, OR検索
public struct MatchSearcher: Searcher {
    private var tokenStream: TokenStream
    private var logic: Logic
    private var storage: Storage
    private var sorter: Sorter?

    public init(tokenStream: TokenStream, logic: Logic, storage: Storage, sorter: Sorter?) {
        self.tokenStream = tokenStream
        self.logic = logic
        self.storage = storage
        self.sorter = sorter
    }

    public func search() -> Result<[Document], Error> {
        // tokenStreamが空の場合は空の結果を返す
        if self.tokenStream.size() == 0 {
            return .success([])
        }

        // トークンIDを取得するためにストレージからトークンを取得する
        let tokens: [Token]
        let result1 = self.storage.getTokenByTerms(tokenStream.terms())

        // エラー処理
        switch result1 {
            case .success(let tks):
                tokens = tks
            case .failure(let error):
                return .failure(error)
        }

        // トークンが見つからない場合は空の結果を返す
        if tokens.count == 0 {
            return .success([])
        }

        // AND検索で対応するトークンが全て存在していなかったら、マッチするドキュメントなしでリターン
        if self.logic == .AND && tokens.count != self.tokenStream.terms().count {
            return .success([])
        }

        // ストレージから転置インデックスを取得する
        let result2 = self.storage.getInvertedIndexByTokenIDs(self.tokenIds(tokens))
        let inverted: InvertedIndex
        // エラー処理
        switch result2 {
            case .success(let inv):
                inverted = inv
            case .failure(let error):
                return .failure(error)
        }

        // ポスティングリストを取得する
        var postings: [Postings] = []
        for token in tokens {
            if let _postings = inverted[token.id]?.postings {
                postings.append(_postings)
            }
        }

        // ポスティングリストをスキャンし、マッチするドキュメントIDを取得する
        let machedIds: [DocumentID]
        if self.logic == .AND {
            machedIds = self.andMatch(postings: postings)
        } else {
            machedIds = self.orMatch(postings: postings)
        }


        // Sorterが指定されている場合はソートする
        let result3 = self.storage.getDocuments(machedIds)
        let documents: [Document]
        // エラー処理
        switch result3 {
            case .success(let docs):
                documents = docs
            case .failure(let error):
                return .failure(error)
        }
        guard let sorter = self.sorter else {
            return .success(documents)
        }

        return sorter.sort(documents: documents, invertedIndex: inverted, tokens: tokens)
    }

    // AND検索
    private func andMatch(postings: [Postings]) -> [DocumentID] {
        var postings:[Postings?] = postings
        var ids: [DocumentID] = []
        while self.notAllNil(postings) {
            if self.isSameDocumentId(postings) {
                ids.append(postings[0]?.documentId ?? 0)
                postings = self.next(postings)
                continue
            }

            let idx = self.minDoucmentIdIndex(postings)
            postings[idx] = postings[idx]?.next
        }
        return ids
    }

    // OR検索
    private func orMatch(postings: [Postings]) -> [DocumentID] {
        var postings: [Postings?] = postings
        var ids: [DocumentID] = []
        while !self.allNil(postings) {
            for (i, p) in postings.enumerated() {
                guard let p else { continue }
                ids.append(p.documentId)
                postings[i] = p.next
            }
        }
        // 重複を削除&ソート
        return Array(Set(ids)).sorted()
    }
}

// フレーズ検索
public struct PhraseSearcher: Searcher {
    private var tokenStream: TokenStream
    private var storage: Storage
    private var sorter: Sorter?

    public init(tokenStream: TokenStream, storage: Storage, sorter: Sorter?) {
        self.tokenStream = tokenStream
        self.storage = storage
        self.sorter = sorter
    }

    public func search() -> Result<[Document], Error> {
        // tokenStreamが空の場合は空の結果を返す
        if self.tokenStream.size() == 0 {
            return .success([])
        }

        // トークンIDを取得するためにストレージからトークンを取得する
        let tokens: [Token]
        let result1 = self.storage.getTokenByTerms(tokenStream.terms())

        // エラー処理
        switch result1 {
            case .success(let tks):
                tokens = tks
            case .failure(let error):
                return .failure(error)
        }

        // トークンが見つからない場合は空の結果を返す
        if tokens.count == 0 {
            return .success([])
        }

        // 対応するトークンが全て存在していなかったら、マッチするドキュメントなしでリターン
        if tokens.count != self.tokenStream.terms().count {
            return .success([])
        }

        // ストレージから転置インデックスを取得する
        let result2 = self.storage.getInvertedIndexByTokenIDs(self.tokenIds(tokens))
        let inverted: InvertedIndex
        // エラー処理
        switch result2 {
            case .success(let inv):
                inverted = inv
            case .failure(let error):
                return .failure(error)
        }

        // ポスティングリストを取得する
        var postings: [Postings] = []
        for token in tokens {
            if let _postings = inverted[token.id]?.postings {
                postings.append(_postings)
            }
        }

        let machedIds = self.fhraseMatch(postings: postings)

        // Sorterが指定されている場合はソートする
        let result3 = self.storage.getDocuments(machedIds)
        let documents: [Document]
        // エラー処理
        switch result3 {
            case .success(let docs):
                documents = docs
            case .failure(let error):
                return .failure(error)
        }
        guard let sorter = self.sorter else {
            return .success(documents)
        }

        return sorter.sort(documents: documents, invertedIndex: inverted, tokens: tokens)
    }

    // フレーズマッチ
    private func fhraseMatch(postings: [Postings]) -> [DocumentID]{
        // ポスティングリストをスキャンし、マッチするドキュメントIDを取得する
        var postings: [Postings?] = postings
        var ids: [DocumentID] = []
        while notAllNil(postings) {
            if isSameDocumentId(postings) {
                if self.isPhraseMatch(tokenStream: tokenStream, postings: postings) {
                    ids.append(postings[0]?.documentId ?? 0)
                }

                postings = next(postings)
                continue
            }

            let idx = minDoucmentIdIndex(postings)
            postings[idx] = postings[idx]?.next!
        }
        return ids
    }

    // TODO: 理解が足りない
    private func isPhraseMatch(tokenStream: TokenStream, postings: [Postings?]) -> Bool {
        // 相対位置リストを作成
        var relativePositions: [[UInt64]] = []
        for i in 0..<tokenStream.size(){
            if let postings = postings[i] {
                relativePositions.append(decremenSlice(s: postings.positions, n: UInt64(i)))
            }
        }

        return self.hasCommon(relativePositions)
    }

    private func decrementSlice(_ postings: [Postings?], _ idx: Int) -> [Postings?] {
        var _postings = postings
        _postings[idx] = _postings[idx]?.next
        return _postings
    }

    // uint64スライスsの各要素をnだけデクリメント
    // TODO: 理解が足りない
    private func decremenSlice(s: [UInt64], n: UInt64) -> [UInt64] {
        var result: [UInt64] = []
        for el in s {
            result.append(el - n)
        }
        return result
    }

    // 複数のスライスが共通の要素を持っているか判定
    // TODO: 理解が足りない
    private func hasCommon(_ ss: [[UInt64]]) -> Bool {
        let s0 = ss[0]
        for s1 in ss[1...] {
            var hasCommon = false
            for v1 in s0 {
                for v2 in s1 {
                    if v1 == v2 {
                        hasCommon = true
                    }
                }
            }
            if !hasCommon {
                return false
            }
        }

        return true
    }
}