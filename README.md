# mosearch | My Own Search Engine

## 概要
Swiftで作成した自作検索エンジンです。（作り途中）

## Todo
- [x] Analyzer
    - [x] CharacterFilter
    - [x] Tokenizer
    - [x] TokenFilter
- [x] Indexer
- [x] Searcher
  - [x] Sorter
- [x] Storage

## Dependencies
- [SQLite](https://github.com/stephencelis/SQLite.swift)

## 参考资料
### 検索エンジン
- [検索エンジン自作入門
～手を動かしながら見渡す検索の舞台裏](https://gihyo.jp/book/2014/978-4-7741-6753-4)
- [WEB+DB PRESS Vol.126 | 作って学ぶ検索エンジンのしくみ
Goで実装！ 膨大な情報からどう高速に探すのか](https://gihyo.jp/magazine/wdpress/archive/2022/vol126)
- [WEB+DB Press Vol.126で「作って学ぶ検索エンジンのしくみ──Goで実装！ 膨大な情報からどう高速に探すのか」という記事を寄稿しました](https://kotaroooo0-dev.hatenablog.com/entry/2021/12/26/145902)
- [情報検索に興味が沸いたのでGoで検索エンジンを自作している](https://kotaroooo0-dev.hatenablog.com/entry/toy-search-engine)

### 漢字からかな・カタカナへの変換
- [漢字をひらがな/カタカナに変換する] https://qiita.com/sgr-ksmt/items/cc8882aa80a59e5a8355
