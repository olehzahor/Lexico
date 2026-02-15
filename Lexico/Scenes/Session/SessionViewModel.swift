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
    private let cardsProvider: any CardsProviding
    let progressTracker: CardsProgressTracking
    private let metricsService: SessionMetricsService

    private let language: String
    private(set) var dailyGoal: Int

    private(set) var activeCard: Card?
    
    var isActiveCardNew: Bool {
        guard let activeCard else { return true }
        guard let progress = progressTracker.getProgressIfExists(for: activeCard.id) else { return true }
        return progress.state == .new
    }

    var todayReviewsCount: Int {
        metricsService.metrics.todayReviewedCount
    }

    var currentLevelCompletionText: String {
        metricsService.metrics.currentLevelCompletion
            .formatted(.percent.precision(.fractionLength(2)))
    }

    var currentLevelTitle: String {
        "\(metricsService.metrics.currentLevel) completion: \(currentLevelCompletionText)"
    }

    func refresh() {
        metricsService.refresh()
        if activeCard == nil {
            activeCard = cardsProvider.getNextCard(for: language)
        }
    }

    func handleCardAction(_ action: CardView.UserAction, for card: Card) {
        switch action {
        case .easy:
            progressTracker.reviewCard(cardID: card.id, grade: .easy, at: .now)
        case .good:
            progressTracker.reviewCard(cardID: card.id, grade: .good, at: .now)
        case .hard:
            progressTracker.reviewCard(cardID: card.id, grade: .hard, at: .now)
        case .ignore:
            progressTracker.ignoreCard(cardID: card.id, ignored: true)
        }

        activeCard = cardsProvider.getNextCard(for: language)
        metricsService.refresh()
    }
    
    init(
        cardsProvider: any CardsProviding,
        progressTracker: CardsProgressTracking,
        metricsService: SessionMetricsService,
        language: String = "en",
        dailyGoal: Int = 20
    ) {
        self.cardsProvider = cardsProvider
        self.progressTracker = progressTracker
        self.language = language
        self.dailyGoal = dailyGoal
        self.metricsService = metricsService
        self.activeCard = cardsProvider.getNextCard(for: language)

        metricsService.refresh()
    }
}
