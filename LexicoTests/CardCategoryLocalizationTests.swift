import XCTest
@testable import Lexico

@MainActor
final class CardCategoryLocalizationTests: XCTestCase {
    func testBundledDecksProvideTheirOwnCategoryNames() {
        let standard = BundleCardsDataSource(filePrefix: "cards").fetchCards(for: "en", deckID: "default")
        let alternate = BundleCardsDataSource(filePrefix: "alt_cards").fetchCards(for: "en", deckID: "alt_cards")

        XCTAssertEqual(standard.count, 2756)
        XCTAssertEqual(alternate.count, 75)
        XCTAssertEqual(standard.first?.categoryName(for: "ru"), "Местоимения: личные")
        XCTAssertEqual(alternate.first?.categoryName(for: "ru"), "Прилагательные")
        for card in standard + alternate {
            XCTAssertFalse(card.categoryNames["en", default: ""].isEmpty, "Missing English category for \(card.word)")
            XCTAssertFalse(card.categoryNames["ru", default: ""].isEmpty, "Missing Russian category for \(card.word)")
        }
    }

    func testDeckMetadataAndOverlappingCardIDs() {
        let decks = BundleCardsDataSource.availableDecks()
        XCTAssertEqual(Set(decks.map(\.id)), ["default", "alt_cards"])
        XCTAssertEqual(decks.first { $0.id == "default" }?.names["ru"], "Обычные карточки")
        XCTAssertEqual(decks.first { $0.id == "alt_cards" }?.language, "en")
    }

    func testCategoryFallsBackToEnglishThenKey() throws {
        let json = """
        {"id":1,"word":"example","part_of_speech":"n","level":"A1",
         "category":"card.category.sample","translations":[],"sentences":[]}
        """
        var card = try JSONDecoder().decode(Card.self, from: Data(json.utf8))
        card.categoryNames = ["en": "Sample", "ru": "Пример"]

        XCTAssertEqual(card.categoryName(for: "ru-RU"), "Пример")
        XCTAssertEqual(card.categoryName(for: "uk"), "Sample")
        card.categoryNames = [:]
        XCTAssertEqual(card.categoryName(for: "ru"), "card.category.sample")
    }
}
