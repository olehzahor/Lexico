//
//  CardsViewModel.swift
//  Lexico
//
//  Created by Codex on 2/14/26.
//

import Foundation
import Observation

@Observable
final class CardsViewModel {
    var activeFilter: CardsFilter {
        didSet { reload() }
    }
    var items: [CardsRowView.Data] = []
    var emptyState: CardsEmptyState

    private let cardsProvider: any CardsProviderProtocol
    private let progressTracker: CardsProgressTrackerProtocol
    private let language: String

    init(
        cardsProvider: any CardsProviderProtocol,
        progressTracker: CardsProgressTrackerProtocol,
        language: String = "en",
        activeFilter: CardsFilter = .review
    ) {
        self.cardsProvider = cardsProvider
        self.progressTracker = progressTracker
        self.language = language
        self.activeFilter = activeFilter
        self.emptyState = .review

        reload()
    }

    func reload() {
        switch activeFilter {
        case .review:
            self.items = cardsProvider.getReviewQueue(for: language).map { CardsRowView.Data(reviewItem: $0) }
            self.emptyState = .review
        case .unseen:
            self.items = cardsProvider.getUnseenCards(for: language).map { CardsRowView.Data(card: $0, status: "Unseen") }
            self.emptyState = .unseen
        case .ignored:
            self.items = cardsProvider.getIgnoredCards(for: language).map { CardsRowView.Data(card: $0, status: "Ignored") }
            self.emptyState = .ignored
        }
    }

    func setIgnored(_ ignored: Bool, for item: CardsRowView.Data) {
        progressTracker.ignoreCard(cardID: item.cardID, ignored: ignored)
        reload()
    }

    var isEmpty: Bool { items.isEmpty }
}
