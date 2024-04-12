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

public class Postings: Codable {
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

    private enum CodingKeys: String, CodingKey {
        case documentId
        case positions
        case next
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(documentId, forKey: .documentId)
        try container.encode(positions, forKey: .positions)
        try container.encode(next, forKey: .next)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.documentId = try container.decode(DocumentID.self, forKey: .documentId)
        self.positions = try container.decode([UInt64].self, forKey: .positions)
        self.next = try container.decodeIfPresent(Postings.self, forKey: .next)
    }
}