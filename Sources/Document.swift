public typealias DocumentID = UInt64
extension DocumentID: Codable {
}

public struct Document {
    var id: DocumentID
    var body: String
    var tokenCount: Int
}
