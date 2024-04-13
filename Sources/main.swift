// The Swift Programming Language
// https://docs.swift.org/swift-book

// ストレージの初期化
let storage = StorageRdbImpl()

// アナライザーの初期化
let analyzer = Analyzer(
    charFilters: [],
    tokenizer: StandardTokenizer(),
    tokenFilters: [
        LowercaseTokenFilter()
    ])

// インデクサーの初期化
let indexer = Indexer(storage: storage, analyzer: analyzer, threshold: 1)

// ドキュメントの追加
let strs = [
    "Ruby PHP JS",
    "Go Ruby",
    "Ruby Go PHP",
    "Go PHP"
]
for str in strs {
    let doc = Document(body: str)
    let result = indexer.addDocument(doc)
    // エラー処理
    switch result {
    case .success:
        print("Success: addDocument")
    case .failure(let error):
        print("Error: \(error)")
    }
}

// OR検索
let sorter = TfidSorter(storage: storage)
let mq = MatchQuery(
    keyword: "GO Ruby",
    logic: Logic.OR,
    analyzer: analyzer,
    sorter: sorter
)
let searcher = mq.searcher(storage: storage)
let result = searcher.search()
// エラー処理
switch result {
case .success(let docs):
    if docs.isEmpty {
        print("Not found")
    }
    for doc in docs {
        print(doc.body)
    }
case .failure(let error):
    print("Error: \(error)")
}