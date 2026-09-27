import SwiftData
import XCTest
@testable import Lexico

@MainActor
final class DeckProgressTests: XCTestCase {
    func testLegacyProgressMigratesAndDecksRemainSeparate() throws {
        let suiteName = "DeckProgressTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = SettingsStore(defaults: defaults)
        let container = try ModelContainer(
            for: CardProgress.self, CardHistory.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let legacy = CardProgress(cardID: 1)
        legacy.deckID = nil
        legacy.ignored = true
        container.mainContext.insert(legacy)
        try container.mainContext.save()

        let tracker = CardsProgressTracker(modelContext: container.mainContext, settingsStore: store)
        XCTAssertEqual(legacy.deckID, "default")
        XCTAssertTrue(tracker.getProgressIfExists(for: 1)?.ignored == true)

        store.set(.activeDeckID, value: .string("alt_cards"))
        XCTAssertNil(tracker.getProgressIfExists(for: 1))
        tracker.reviewCard(cardID: 1, grade: .good)
        XCTAssertEqual(tracker.getProgressIfExists(for: 1)?.deckID, "alt_cards")
        XCTAssertFalse(tracker.getProgressIfExists(for: 1)?.ignored == true)

        store.set(.activeDeckID, value: .string("default"))
        XCTAssertTrue(tracker.getProgressIfExists(for: 1)?.ignored == true)
    }
}
