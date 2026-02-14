//
//  QueueViewModel+QueueEmptyState.swift
//  Lexico
//
//  Created by Codex on 2/14/26.
//

import Foundation

extension QueueViewModel {
    struct QueueEmptyState {
        let title: String
        let description: String
        let systemImage: String

        static let review = QueueEmptyState(
            title: "No cards to review",
            description: "Cards will appear here when they become due.",
            systemImage: "clock"
        )

        static let unseen = QueueEmptyState(
            title: "No unseen cards",
            description: "New cards will appear here.",
            systemImage: "clock"
        )

        static let ignored = QueueEmptyState(
            title: "No ignored cards",
            description: "You haven't ignored any cards yet.",
            systemImage: "clock"
        )
    }
}
