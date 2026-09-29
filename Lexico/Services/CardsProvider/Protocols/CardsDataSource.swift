//
//  CardsDataSource.swift
//  Lexico
//
//  Created by Codex on 2/15/26.
//

import Foundation

protocol CardsDataSource {
    func fetchDeck(for deckID: String, language: String) -> Deck?
    func fetchCards(for lang: String, deckID: String) -> [Card]
}
