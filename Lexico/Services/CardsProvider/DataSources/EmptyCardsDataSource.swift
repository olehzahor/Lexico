//
//  EmptyCardsDataSource.swift
//  Lexico
//
//  Created by Codex on 2/15/26.
//

import Foundation

struct EmptyCardsDataSource: CardsDataSource {
    func fetchCards(for lang: String) -> [Card] {
        []
    }
}
