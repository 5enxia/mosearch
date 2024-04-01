import Foundation

public protocol Sorter {
    func sort(documents: [Document], invertedIndex: InvertedIndex, tokens: [Token]) -> Result<[Document], Error>
}

public struct TfidSorter: Sorter {
    var storage: Storage

    // TODO: あとで実装する
    public func sort(documents: [Document], invertedIndex: InvertedIndex, tokens: [Token]) -> Result<[Document], Error> {
        let result1 = self.storage.countDocuments()
        let allDocsCount: Int
        switch result1 {
            case .success(let count):
                allDocsCount = count
            case .failure(let error):
                return .failure(error)
        }

        var documentScores: DocumentScores = []
        for doc in documents {
            var score: Float64 = 0
            for token in tokens {
                if let postingList = invertedIndex[token.id] {
                    let tf = Float64(postingList.appearanceCountInDocument(doc.id)) / Float64(doc.tokenCount)
                    let idf = log2(Float64(allDocsCount) / Float64(postingList.size() + 1)) + 1
                    score += tf * idf
                }
            }
            documentScores.append(DocumentScore(document: doc, score: score))
        }

        let sorted = documentScores.sorted(by: >)
        return .success(sorted.toDocuments())
    }
}

public struct DocumentScore {
	let document: Document
	let score: Float64
}

extension DocumentScore: Equatable {
    public static func == (lhs: DocumentScore, rhs: DocumentScore) -> Bool {
        lhs.document.id == rhs.document.id
    }
}

extension DocumentScore: Comparable {
    public static func < (lhs: DocumentScore, rhs: DocumentScore) -> Bool {
        lhs.score < rhs.score
    }
}

typealias DocumentScores = [DocumentScore]
extension DocumentScores {
    func len() -> Int {
        return self.count
    }
    func toDocuments() -> [Document] {
        return self.map { $0.document }
    }
}