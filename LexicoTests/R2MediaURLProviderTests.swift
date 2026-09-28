import XCTest
@testable import Lexico

final class R2MediaURLProviderTests: XCTestCase {
    func testObjectPathsIncludeDeckID() {
        let provider = R2MediaURLProvider(
            baseURLString: "https://example.r2.cloudflarestorage.com",
            bucket: "audio",
            accessKeyID: "test-key",
            secretAccessKey: "test-secret"
        )

        XCTAssertEqual(provider.wordURL(for: 1, deckID: "default")?.path, "/audio/default/words/001.m4a")
        XCTAssertEqual(provider.sentenceURL(for: 101, deckID: "alt_cards")?.path, "/audio/alt_cards/sentences/101.m4a")
        XCTAssertNil(provider.wordURL(for: 1, deckID: "../other"))
    }
}
