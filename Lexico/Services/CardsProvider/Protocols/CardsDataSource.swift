//
//  CardsDataSource.swift
//  Lexico
//
//  Created by Codex on 2/15/26.
//

import Foundation

protocol CardsDataSource {
    func fetchCards(for lang: String) -> [Card]
}
