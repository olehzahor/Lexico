//
//  CardsProvider.swift
//  Lexico
//
//  Created by user on 2/1/26.
//

import Foundation

final class CardsProvider {
    private static let jsonDecoder = JSONDecoder()
    private let progressTracker: CardsProgressTracker
    
    private var cardsCache: [String: [Card]] = [:]

    func getAllCards(for lang: String) -> [Card] {
        if let cachedCards = cardsCache[lang] {
            return cachedCards
        }
        
        guard let url = Bundle.main.url(forResource: "cards_\(lang)", withExtension: "json") else {
            print("⚠️ Could not find cards_\(lang).json")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let response = try Self.jsonDecoder.decode(CardsResponse.self, from: data)
            let cards = response.words
            cardsCache[lang] = cards
            return cards
        } catch {
            print("⚠️ Error loading cards: \(error)")
            return []
        }
    }
    
    func getReviewQueue(for lang: String) -> [ReviewQueueItem] {
        let allCards = getAllCards(for: lang)
        let allCardsForReview = progressTracker.getAllCardsForReview()

        let progressMap = Dictionary(uniqueKeysWithValues: allCardsForReview.map { ($0.cardID, $0) })

        return allCards
            .compactMap { card -> ReviewQueueItem? in
                guard let progress = progressMap[card.id] else { return nil }
                return .init(card: card, progress: progress)
            }
            .sorted { a, b in
                let aKey = a.dueAt ?? .distantPast
                let bKey = b.dueAt ?? .distantPast
                if aKey != bKey { return aKey < bKey }
                return a.card.id < b.card.id
            }
    }
    
    func getAllCardsForReview(for lang: String) -> [Card] {
        let allCards = getAllCards(for: lang)
        let allReviewProgress = progressTracker.getAllCardsForReview()
        let allReviewIDs = Set(allReviewProgress.map(\.cardID))
        return allCards.filter { allReviewIDs.contains($0.id) }
    }

    func getCardsReadyForReview(for lang: String, at date: Date = .now) -> [Card] {
        let allCards = getAllCards(for: lang)
        let dueProgress = progressTracker.getCardsDueForReview(at: date)
        let dueCardIDs = Set(dueProgress.map(\.cardID))
        return allCards.filter { dueCardIDs.contains($0.id) }
    }

    func getIgnoredCards(for lang: String) -> [Card] {
        let allCards = getAllCards(for: lang)
        let ignoredIDs = Set(progressTracker.getIgnoredCards().map(\.cardID))
        return allCards.filter { ignoredIDs.contains($0.id) }
    }

    func getUnseenCards(for lang: String) -> [Card] {
        let allCards = getAllCards(for: lang)
        let ignoredIDs = Set(getIgnoredCards(for: lang).map(\.id))
        let allReviewIDs = Set(getAllCardsForReview(for: lang).map(\.id))
        return allCards.filter { ignoredIDs.contains($0.id) == false && allReviewIDs.contains($0.id) == false }
    }

    func getNextCard(for lang: String) -> Card? {
        if let reviewCard = getCardsReadyForReview(for: lang).first {
            return reviewCard
        }

        return getUnseenCards(for: lang).first
    }
    
    init(progressManager: CardsProgressTracker) {
        self.progressTracker = progressManager
    }
}

private extension CardsProvider {
    struct CardsResponse: Codable {
        let words: [Card]
    }
}
