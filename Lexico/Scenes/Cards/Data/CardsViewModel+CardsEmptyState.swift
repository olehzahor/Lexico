//
//  CardsViewModel+CardsEmptyState.swift
//  Lexico
//
//  Created by Codex on 2/14/26.
//

import Foundation

extension CardsViewModel {
    struct CardsEmptyState {
        let title: String
        let description: String
        let systemImage: String

        static let review = CardsEmptyState(
            title: String(localized: "No cards to review", comment: "Cards screen empty state title"),
            description: String(localized: "Cards will appear here when they become due.", comment: "Cards screen empty state description"),
            systemImage: "clock"
        )

        static let unseen = CardsEmptyState(
            title: String(localized: "No unseen cards", comment: "Cards screen empty state title"),
            description: String(localized: "New cards will appear here.", comment: "Cards screen empty state description"),
            systemImage: "clock"
        )

        static let ignored = CardsEmptyState(
            title: String(localized: "No ignored cards", comment: "Cards screen empty state title"),
            description: String(localized: "You haven't ignored any cards yet.", comment: "Cards screen empty state description"),
            systemImage: "clock"
        )
    }
}
