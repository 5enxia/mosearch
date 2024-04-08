public typealias DocumentID = UInt64
extension DocumentID {
    public func toBytes() -> [Byte] {
        var bytes: [Byte] = []
        bytes.append(contentsOf: withUnsafeBytes(of: self) { $0 })
        return bytes
    }
}

public struct Document {
    var id: DocumentID
    var body: String
    var tokenCount: Int
}
