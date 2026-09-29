//
//  EmptyCardsDataSource.swift
//  Lexico
//
//  Created by Codex on 2/15/26.
//

import Foundation

struct EmptyCardsDataSource: CardsDataSource {
    func fetchDeck(for deckID: String, language: String) -> Deck? {
        nil
    }

    func fetchCards(for lang: String, deckID: String) -> [Card] {
        []
    }
}
