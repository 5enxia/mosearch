import Foundation

public protocol CharFilter {
    func filter(_ s: String) -> String
}

public struct MappingCharFilter: CharFilter {
    private let mapper: [String: String]

    public init(mapper: [String: String]) {
        self.mapper = mapper
    }

    public func filter(_ s: String) -> String {
        var s = s
        for (from, to) in mapper {
            s = s.replacingOccurrences(of: from, with: to)
        }
        return s
    }
}