//
//  QueueViewModel.swift
//  Lexico
//
//  Created by Codex on 2/14/26.
//

import Foundation
import Observation

@Observable
final class QueueViewModel {
    var activeFilter: QueueFilter {
        didSet { reload() }
    }
    var items: [QueueRowView.Data] = []
    var emptyState: QueueEmptyState

    private let cardsProvider: CardsProvider
    private let language: String

    init(
        cardsProvider: CardsProvider,
        language: String = "en",
        activeFilter: QueueFilter = .reviewQueue
    ) {
        self.cardsProvider = cardsProvider
        self.language = language
        self.activeFilter = activeFilter
        self.emptyState = .review

        reload()
    }

    func reload() {
        switch activeFilter {
        case .reviewQueue:
            self.items = cardsProvider.getReviewQueue(for: language).map { QueueRowView.Data(reviewItem: $0) }
            self.emptyState = .review
        case .unseen:
            self.items = cardsProvider.getUnseenCards(for: language).map { QueueRowView.Data(card: $0, status: "Unseen") }
            self.emptyState = .unseen
        case .ignored:
            self.items = cardsProvider.getIgnoredCards(for: language).map { QueueRowView.Data(card: $0, status: "Ignored") }
            self.emptyState = .ignored
        }
    }

    var isEmpty: Bool { items.isEmpty }
}
