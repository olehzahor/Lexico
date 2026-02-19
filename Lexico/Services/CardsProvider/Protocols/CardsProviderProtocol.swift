//
//  CardsProviderProtocol.swift
//  Lexico
//
//  Created by Codex on 2/15/26.
//

import Foundation

protocol CardsProviderProtocol: AnyObject {
    func getAllCards(for lang: String) -> [Card]
    func getReviewQueue(for lang: String) -> [ReviewQueueItem]
    func getAllCardsForReview(for lang: String) -> [Card]
    func getCardsReadyForReview(for lang: String, at date: Date?) -> [Card]
    func getIgnoredCards(for lang: String) -> [Card]
    func getUnseenCards(for lang: String) -> [Card]
    func getNextCard(for lang: String, at date: Date?) -> Card?
}

extension CardsProviderProtocol {
    func getCardsReadyForReview(for lang: String) -> [Card] {
        getCardsReadyForReview(for: lang, at: nil)
    }

    func getNextCard(for lang: String) -> Card? {
        getNextCard(for: lang, at: nil)
    }
}
