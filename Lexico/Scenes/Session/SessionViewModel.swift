//
//  SessionViewModel.swift
//  Lexico
//
//  Created by Codex on 2/15/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class SessionViewModel {
    private let cardsProvider: any CardsProviderProtocol
    let progressTracker: CardsProgressTrackerProtocol
    private let metricsService: SessionMetricsService

    private let language: String
    private(set) var dailyGoal: Int

    private(set) var activeCard: Card?
    private(set) var activeCardData: CardView.Data?

    var todayReviewsCount: Int {
        metricsService.metrics.todayReviewedCount
    }

    var currentLevelCompletionText: String {
        metricsService.metrics.currentLevelCompletion
            .formatted(.percent.precision(.fractionLength(2)))
    }

    var currentLevelTitle: String {
        "\(metricsService.metrics.currentLevel) \(String(localized: "completion", comment: "Session metrics label")): \(currentLevelCompletionText)"
    }

    func refresh() {
        metricsService.refresh()
        if activeCard == nil {
            setActiveCard(cardsProvider.getNextCard(for: language))
        }
    }

    func handleCardAction(_ action: CardView.UserAction, for cardID: Int) {
        switch action {
        case .easy:
            progressTracker.reviewCard(cardID: cardID, grade: .easy, at: .now)
        case .good:
            progressTracker.reviewCard(cardID: cardID, grade: .good, at: .now)
        case .hard:
            progressTracker.reviewCard(cardID: cardID, grade: .hard, at: .now)
        case .ignore:
            progressTracker.ignoreCard(cardID: cardID, ignored: true)
        }

        setActiveCard(cardsProvider.getNextCard(for: language))
        metricsService.refresh()
    }
    
    private func setActiveCard(_ card: Card?) {
        self.activeCard = card
        guard let card else {
            self.activeCardData = nil
            return
        }

        let isNew = (progressTracker.getProgressIfExists(for: card.id)?.state ?? .new) == .new
        self.activeCardData = CardView.Data(card: card, isNew: isNew)
    }

    init(
        cardsProvider: any CardsProviderProtocol,
        progressTracker: CardsProgressTrackerProtocol,
        metricsService: SessionMetricsService,
        language: String = "en",
        dailyGoal: Int = 20
    ) {
        self.cardsProvider = cardsProvider
        self.progressTracker = progressTracker
        self.language = language
        self.dailyGoal = dailyGoal
        self.metricsService = metricsService
        setActiveCard(cardsProvider.getNextCard(for: language))

        metricsService.refresh()
    }
}
