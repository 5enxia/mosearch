public typealias DocumentID = UInt64
extension DocumentID: Codable {
}

public struct Document {
    var id: DocumentID
    var body: String
    var tokenCount: Int

    public init(id: DocumentID = 0, body: String = "", tokenCount: Int = 0) {
        self.id = id
        self.body = body
        self.tokenCount = tokenCount
    }
}
