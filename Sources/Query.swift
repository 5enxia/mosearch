public struct MatchQuery {
    var keyword: String
    var logic: Logic
    var analyzer: Analyzer
    var sorter: Sorter

    public func searcher(storage: Storage) -> Searcher {
        let tokenStream = self.analyzer.analyze(self.keyword)
        return MatchSearcher(tokenStream: tokenStream, logic: self.logic, storage: storage, sorter: self.sorter)
    }
}

public struct PhraseQuery {
    var phrase: String
    var analyzer: Analyzer
    var sorter: Sorter

    public func searcher(storage: Storage) -> Searcher {
        let tokenStream = self.analyzer.analyze(self.phrase)
        return PhraseSearcher(tokenStream: tokenStream, storage: storage, sorter: self.sorter)
    }
}