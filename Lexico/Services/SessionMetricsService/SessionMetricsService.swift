//
//  SessionMetricsService.swift
//  Lexico
//
//  Created by Codex on 2/15/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class SessionMetricsService {
    struct Metrics {
        var todayReviewedCount: Int
        var currentLevel: String
        var reviewCountOnCurrentLevel: Int
        var dueReviewCountOnCurrentLevel: Int
        var currentLevelCompletion: Double
    }

    var metrics: Metrics

    private let progressTracker: SessionMetricsProgressReader & CardsProgressTrackerProtocol
    private let cardsProvider: any CardsProviderProtocol
    private let language: String
    private let defaultLevel: String

    init(
        progressTracker: SessionMetricsProgressReader & CardsProgressTrackerProtocol,
        cardsProvider: any CardsProviderProtocol,
        language: String = "en",
        defaultLevel: String = "A1"
    ) {
        self.progressTracker = progressTracker
        self.cardsProvider = cardsProvider
        self.language = language
        self.defaultLevel = defaultLevel
        self.metrics = Metrics(
            todayReviewedCount: 0,
            currentLevel: defaultLevel,
            reviewCountOnCurrentLevel: 0,
            dueReviewCountOnCurrentLevel: 0,
            currentLevelCompletion: 0
        )

        let progressChanges = progressTracker.progressChanges
        Task { [weak self] in
            for await _ in progressChanges {
                await MainActor.run {
                    self?.refresh()
                }
            }
        }
    }

    func refresh(now: Date = .now) {
        let allCards = cardsProvider.getAllCards(for: language)
        guard allCards.isEmpty == false else {
            metrics = Metrics(
                todayReviewedCount: 0,
                currentLevel: defaultLevel,
                reviewCountOnCurrentLevel: 0,
                dueReviewCountOnCurrentLevel: 0,
                currentLevelCompletion: 0
            )
            return
        }

        let highestSeenID = progressTracker.fetchHighestSeenCardID()
        let currentLevel = allCards.first(where: { $0.id == highestSeenID })?.level ?? defaultLevel
        let levelCardIDs = Set(allCards.filter { $0.level == currentLevel }.map(\.id))

        let todayReviewedCount = progressTracker.fetchReviewedTodayCount(now: now)
        let reviewCountOnCurrentLevel = progressTracker.fetchReviewCount(forCardIDs: levelCardIDs)
        let dueReviewCountOnCurrentLevel = progressTracker.fetchDueReviewCount(forCardIDs: levelCardIDs, at: now)
        let ignoredCountOnCurrentLevel = progressTracker.fetchIgnoredCount(forCardIDs: levelCardIDs)

        let eligibleCount = max(0, levelCardIDs.count - ignoredCountOnCurrentLevel)
        let completion = eligibleCount == 0 ? 0 : Double(reviewCountOnCurrentLevel) / Double(eligibleCount)

        metrics = Metrics(
            todayReviewedCount: todayReviewedCount,
            currentLevel: currentLevel,
            reviewCountOnCurrentLevel: reviewCountOnCurrentLevel,
            dueReviewCountOnCurrentLevel: dueReviewCountOnCurrentLevel,
            currentLevelCompletion: completion
        )
    }
}
