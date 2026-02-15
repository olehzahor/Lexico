//
//  CardsProviderProgressReading.swift
//  Lexico
//
//  Created by user on 2/15/26.
//

import Foundation

@MainActor
protocol CardsProviderProgressReading: AnyObject {
    func fetchIgnoredCards() -> [CardProgress]
    func fetchAllCardsForReview() -> [CardProgress]
    func fetchCardsDueForReview(at date: Date) -> [CardProgress]
}

extension CardsProgressTracker: CardsProviderProgressReading {}
