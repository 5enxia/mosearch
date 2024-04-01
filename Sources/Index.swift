public typealias InvertedIndex = [TokenID: PostingList]
extension InvertedIndex {
    public func tokenIds() -> [TokenID] {
        return self.keys.map { TokenID($0) }
    }

}

public struct PostingList {
    var postings: Postings

    // ポスティングリストのサイズ（ドキュメント数）を返す
    public func size() -> Int {
        var size = 0
        var current: Postings? = self.postings
        while current != nil {
            size += 1
            current = current?.next
        }
        return size
    }

    // あるドキュメントID内のトークンの出現数を返す
    public func appearanceCountInDocument(_ documentId: DocumentID) -> Int {
        var count = 0
        var current: Postings? = self.postings
        while current != nil {
            guard let cur = current else { break }
            if cur.documentId == documentId {
                count = cur.positions.count
                break
            }
            guard let next = cur.next else { break }
            current = next
        }

        return count
    }
}

public class Postings {
    var documentId: DocumentID = 0
    var positions: [UInt64] = []
    var next: Postings? = nil

    public init(documentId: DocumentID, positions: [UInt64], next: Postings? = nil) {
        self.documentId = documentId
        self.positions = positions
    }

    public func pushBack(_ postings: Postings) {
        // before: self -> next
        // after: self -> postings -> next
        postings.next = self.next
        self.next = postings
    }
}