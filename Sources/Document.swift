public typealias DocumentID = UInt64

public struct Document {
    var id: DocumentID
    var body: String
    var tokenCount: Int
}
