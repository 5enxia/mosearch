public class Indexer {
    // 永続化層
    private let storage: Storage
    // ドキュメントをトークン化するためのアナライザ
    private let analyzer: Analyzer
    // メモリ上の転置インデックス
    private var invertedIndex: InvertedIndex
    // メモリから永続化層に書き込む際の閾値
    private let threshold: UInt64

    // public init(storage: Storage, analyzer: Analyzer, invertedIndex: InvertedIndex, threshold: UInt64) {
    public init(storage: Storage, analyzer: Analyzer, threshold: UInt64) {
        self.storage = storage
        self.analyzer = analyzer
        self.invertedIndex = InvertedIndex()
        self.threshold = threshold
    }

    public func addDocument(_ doc: Document) -> Result<Void, Error> {
        // ドキュメントをトークンに分解する
        var doc = doc
        let tokens = self.analyzer.analyze(doc.body)
        doc.tokenCount = tokens.size()

        // ストレージにドキュメントを保存し、ストレージの自動ID割り当てにより、IDを取得
        let result1 = self.storage.addDocument(doc)
        let docId: DocumentID
        // エラー処理
        switch result1 {
        case .success(let id):
            docId = id
        case .failure(let error):
            return .failure(error)
        }

        // ドキュメントからメモリ上の転置インデックスを更新
        let result2 = self.updateMemoryInvertedIndexByDocument(docId, tokens)
        // エラー処理
        switch result2 {
        case .success:
            break 
        case .failure(let error):
            return .failure(error)
        }

        // メモリ上の転置インデックスのサイズをチェック
        // 閾値を超えた場合、永続化層に書き込む
        // 閾値未満であれば関数を終了
        if self.invertedIndex.count < self.threshold {
            return .success(())
        }

        // マージする転置リストをストレージから取得
        let result3 = self.storage.getInvertedIndexByTokenIDs(Array(self.invertedIndex.tokenIds()))
        let storageInvertedIndex: InvertedIndex
        // エラー処理
        switch result3 {
        case .success(let index):
            storageInvertedIndex = index
        case .failure(let error):
            return .failure(error)
        }

        // メモリ上の転置インデックスとストレージの転置インデックスをマージ
        for (tableId, postingList) in self.invertedIndex {
            let memory = postingList
            guard let storage = storageInvertedIndex[tableId] else { return .success(()) }
            self.invertedIndex[tableId] = self.merge(memory, storage)
        } 

        // マージしたインデックスをストレージに書き込む
        let result4 = self.storage.upsertInvertedIndex(self.invertedIndex)
        switch result4 {
        case .success:
            break
        case .failure(let error):
            return .failure(error)
        }

        // メモリの転置インデックスをクリア
        self.invertedIndex = [:]

        return .success(())
    }

    private func updateMemoryInvertedIndexByDocument(_ docId: DocumentID, _ tokens: TokenStream) -> Result<Void, Error> {
        for (pos, token) in tokens.tokens.enumerated() {
            let result = self.updateMemoryPostingListByToken(docId, token, UInt64(pos))
            switch result {
            case .success:
                break
            case .failure(let error):
                return .failure(error)
            }
        }
        return .success(())
    }

    private func updateMemoryPostingListByToken(_ docId: DocumentID, _ token: Token , _ pos: UInt64) -> Result<Void, Error>{
        // トークンをストレージから取得
        let sToken: Token?
        let tokenId: TokenID

        let result1 = self.storage.getTokenByTerm(token.term)
        switch result1 {
        case .success(let token):
            sToken = token
        case .failure(let error):
            return .failure(error)
        }

        if sToken == nil {
            let result2 = self.storage.addToken(Token(term: token.term))
            switch result2 {
                case .success(let id):
                    tokenId = id
                case .failure(let error):
                    return .failure(error)
            }
        } else {
            // TODO: 強制アンラップを避たい
            tokenId = sToken!.id
        }

        let postingList = self.invertedIndex[tokenId]
        // メモリ上に転置リストが存在するかどうかをチェック
        // ない時
        guard var postingList = postingList else {
            // ポスティングリストを作成
            self.invertedIndex[tokenId] = PostingList(postings: Postings(documentId: docId, positions: [pos], next: nil))
            return .success(())
        }
        // ある時
        // ドキュメントに対応するポスチングがポスティングリストに存在するかどうかをチェック
        // 存在する：nilになる前にループが終了する
        // 存在しない：nilになる
        var p: Postings? = postingList.postings
        // TODO; Unwrapwをguard letに変更したい
        while p != nil && p?.documentId != docId {
            p = p?.next
        }

        // 対象ドキュメントのポスティングが存在するとき
        if p != nil {
            // TODO: 強制アンラップを避たい
            p!.positions.append(pos)
            return .success(())
        }

        // 対象ドキュメントのポスティングが存在しないとき
        // 追加するドキュメントのIDが最小かどうかをチェック
        if docId < postingList.postings.documentId {
            // 最小の場合
            postingList.postings = Postings(documentId: docId, positions: [pos], next: postingList.postings)
            self.invertedIndex[tokenId] = postingList
            return .success(())
        } else {
            // 最小でない場合
            // ポスティングを挿入する位置を探す
            var t = postingList.postings
            // TODO; Unwrapwをguard letに変更したい
            while t.next != nil && t.next!.documentId < docId {
                t = t.next!
            }
            // ポスティングを挿入
            t.pushBack(Postings(documentId: docId, positions: [pos]))
            self.invertedIndex[tokenId] = postingList
            return .success(())
        }
    }

    // TODO: あとで実装
    private func merge(_ memory: PostingList, _ storage: PostingList) -> PostingList {
        return memory
    }
}