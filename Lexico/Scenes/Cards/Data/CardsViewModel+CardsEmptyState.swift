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
            title: "No cards to review",
            description: "Cards will appear here when they become due.",
            systemImage: "clock"
        )

        static let unseen = CardsEmptyState(
            title: "No unseen cards",
            description: "New cards will appear here.",
            systemImage: "clock"
        )

        static let ignored = CardsEmptyState(
            title: "No ignored cards",
            description: "You haven't ignored any cards yet.",
            systemImage: "clock"
        )
    }
}
