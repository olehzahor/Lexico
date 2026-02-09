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
        let allProgress = progressTracker.getAllProgress()

        let progressMap = Dictionary(uniqueKeysWithValues: allProgress.map { ($0.cardID, $0) })

        // Queue is sorted for UI usage: ready first (nil/past dueAt), then by dueAt ascending.
        // Stable tie-breaker: card id.
        return allCards
            .compactMap { card -> ReviewQueueItem? in
                guard let progress = progressMap[card.id] else { return nil }
                guard progress.ignored == false else { return nil }
                return .init(card: card, progress: progress)
            }
            .sorted { a, b in
                let aKey = a.dueAt ?? .distantPast
                let bKey = b.dueAt ?? .distantPast
                if aKey != bKey { return aKey < bKey }
                return a.card.id < b.card.id
            }
    }

    func getCardsForReview(for lang: String, at date: Date = .now) -> [Card] {
        let allCards = getAllCards(for: lang)
        let allProgress = progressTracker.getAllProgress()

        let progressMap = Dictionary(uniqueKeysWithValues: allProgress.map { ($0.cardID, $0) })

        return allCards.filter { card in
            guard let progress = progressMap[card.id] else {
                return false
            }

            if progress.ignored {
                return false
            }

            guard let dueAt = progress.dueAt else {
                return true
            }

            return dueAt <= date
        }
    }

    func getCardsWithProgress(for lang: String) -> [Card] {
        let allCards = getAllCards(for: lang)
        let allProgress = progressTracker.getAllProgress()

        let progressCardIDs = Set(allProgress.map { $0.cardID })
        return allCards.filter { progressCardIDs.contains($0.id) }
    }

    func getNewCards(for lang: String) -> [Card] {
        let allCards = getAllCards(for: lang)
        let cardsWithProgress = getCardsWithProgress(for: lang)
        let progressCardIDs = Set(cardsWithProgress.map { $0.id })
        return allCards.filter { !progressCardIDs.contains($0.id) }
    }

    func getNextCard(for lang: String) -> Card? {
        if let reviewCard = getCardsForReview(for: lang).first {
            return reviewCard
        }

        return getNewCards(for: lang).first
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
