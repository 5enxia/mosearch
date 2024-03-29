// QiitaTests.swift
import XCTest
import Mosearch

final class MosearchTests: XCTestCase {
    func testSearch() throws {
        let str = MosearchCore.search()
        XCTAssertEqual(str, "Mosearch")
    }

    static var allTests = [
        ("testSearch", testSearch),
    ]
}