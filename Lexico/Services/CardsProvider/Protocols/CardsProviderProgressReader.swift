//
//  CardsProviderProgressReader.swift
//  Lexico
//
//  Created by user on 2/15/26.
//

import Foundation

@MainActor
protocol CardsProviderProgressReader: AnyObject {
    func fetchIgnoredCards() -> [CardProgress]
    func fetchAllCardsForReview() -> [CardProgress]
    func fetchCardsDueForReview(at date: Date) -> [CardProgress]
}

extension CardsProgressTracker: CardsProviderProgressReader {}
