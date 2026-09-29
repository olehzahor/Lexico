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
        var todayLearnedNewCardsCount: Int
        var isLeveledDeck: Bool
        var currentLevel: String
        var reviewCountOnCurrentLevel: Int
        var dueReviewCountOnCurrentLevel: Int
        var currentLevelCompletion: Double
        var overallCompletion: Double
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
            todayLearnedNewCardsCount: 0,
            isLeveledDeck: false,
            currentLevel: defaultLevel,
            reviewCountOnCurrentLevel: 0,
            dueReviewCountOnCurrentLevel: 0,
            currentLevelCompletion: 0,
            overallCompletion: 0
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
        let isLeveledDeck = cardsProvider.getActiveDeck(for: language)?.leveled ?? false
        let allCards = cardsProvider.getAllCards(for: language)
        guard allCards.isEmpty == false else {
            metrics = Metrics(
                todayLearnedNewCardsCount: 0,
                isLeveledDeck: isLeveledDeck,
                currentLevel: defaultLevel,
                reviewCountOnCurrentLevel: 0,
                dueReviewCountOnCurrentLevel: 0,
                currentLevelCompletion: 0,
                overallCompletion: 0
            )
            return
        }

        let highestSeenID = progressTracker.fetchHighestSeenCardID()
        let currentLevel = allCards.first(where: { $0.id == highestSeenID })?.level ?? defaultLevel
        let levelCardIDs = Set(allCards.filter { $0.level == currentLevel }.map(\.id))

        let todayLearnedNewCardsCount = progressTracker.fetchNewCardsLearnedTodayCount(now: now)
        let reviewCountOnCurrentLevel = progressTracker.fetchReviewCount(forCardIDs: levelCardIDs)
        let dueReviewCountOnCurrentLevel = progressTracker.fetchDueReviewCount(forCardIDs: levelCardIDs, at: now)
        let ignoredCountOnCurrentLevel = progressTracker.fetchIgnoredCount(forCardIDs: levelCardIDs)

        let eligibleCount = max(0, levelCardIDs.count - ignoredCountOnCurrentLevel)
        let completion = eligibleCount == 0 ? 0 : Double(reviewCountOnCurrentLevel) / Double(eligibleCount)

        let allCardIDs = Set(allCards.map(\.id))
        let reviewCountOverall = progressTracker.fetchReviewCount(forCardIDs: allCardIDs)
        let ignoredCountOverall = progressTracker.fetchIgnoredCount(forCardIDs: allCardIDs)
        let eligibleOverallCount = max(0, allCardIDs.count - ignoredCountOverall)
        let overallCompletion = eligibleOverallCount == 0
            ? 0
            : Double(reviewCountOverall) / Double(eligibleOverallCount)

        metrics = Metrics(
            todayLearnedNewCardsCount: todayLearnedNewCardsCount,
            isLeveledDeck: isLeveledDeck,
            currentLevel: currentLevel,
            reviewCountOnCurrentLevel: reviewCountOnCurrentLevel,
            dueReviewCountOnCurrentLevel: dueReviewCountOnCurrentLevel,
            currentLevelCompletion: completion,
            overallCompletion: overallCompletion
        )
    }
}
