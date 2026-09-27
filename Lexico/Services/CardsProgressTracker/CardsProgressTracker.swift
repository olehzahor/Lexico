//
//  ProgressManager.swift
//  Lexico
//
//  Created by user on 2/1/26.
//

import Foundation
import SwiftData

@MainActor
class CardsProgressTracker {
    private let modelContext: ModelContext
    private let settingsStore: SettingsStoreProtocol
    var activeDeckID: String { settingsStore.get(.activeDeckID, default: .string("default")).string ?? "default" }
    private var progressChangesContinuation: AsyncStream<Void>.Continuation?
    lazy var progressChanges: AsyncStream<Void> = {
        AsyncStream { [weak self] continuation in
            self?.progressChangesContinuation = continuation
        }
    }()

    // MARK: - Lifecycle
    init(modelContext: ModelContext, settingsStore: SettingsStoreProtocol? = nil) {
        self.modelContext = modelContext
        self.settingsStore = settingsStore ?? SettingsStore()
        migrateLegacyRecords()
    }

    private func migrateLegacyRecords() {
        for progress in (try? modelContext.fetch(FetchDescriptor<CardProgress>())) ?? [] where progress.deckID == nil {
            progress.deckID = "default"
        }
        for history in (try? modelContext.fetch(FetchDescriptor<CardHistory>())) ?? [] where history.deckID == nil {
            history.deckID = "default"
        }
        try? modelContext.save()
    }

    private func currentProgress() -> [CardProgress] {
        let deckID = activeDeckID
        return ((try? modelContext.fetch(FetchDescriptor<CardProgress>())) ?? []).filter { ($0.deckID ?? "default") == deckID }
    }

    // MARK: - CardsProgressTrackerProtocol
    func reviewCard(cardID: Int, grade: ReviewGrade, at date: Date = .now) {
        let progress = getProgress(for: cardID)
        progress.apply(grade, now: date)
        try? modelContext.save()
        progressChangesContinuation?.yield(())
    }

    func ignoreCard(cardID: Int, ignored: Bool) {
        let progress = getProgress(for: cardID)
        progress.setIgnored(ignored)
        try? modelContext.save()
        progressChangesContinuation?.yield(())
    }

    // MARK: - CardsProgressTrackerProtocol (Read)
    func getAllProgress() -> [CardProgress] { currentProgress() }

    func getProgress(for cardID: Int) -> CardProgress {
        if let existing = getProgressIfExists(for: cardID) { return existing }
        let progress = CardProgress(cardID: cardID, deckID: activeDeckID)
        modelContext.insert(progress)
        return progress
    }

    func getProgressIfExists(for cardID: Int) -> CardProgress? {
        currentProgress().first { $0.cardID == cardID }
    }

    // MARK: - CardsProviderProgressReader
    func fetchIgnoredCards() -> [CardProgress] { currentProgress().filter(\.ignored) }
    func fetchAllCardsForReview() -> [CardProgress] {
        currentProgress().filter { !$0.ignored && ($0.state == .learning || $0.state == .review) }
    }
    func fetchCardsDueForReview(at date: Date) -> [CardProgress] {
        fetchAllCardsForReview().filter { ($0.dueAt ?? .distantFuture) <= date }
    }

    // MARK: - SessionMetricsProgressReader
    func fetchNewCardsLearnedTodayCount(now: Date = .now) -> Int {
        let calendar = Calendar.autoupdatingCurrent
        let start = calendar.startOfDay(for: now)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? now
        return currentProgress().filter { ($0.firstReviewed ?? .distantPast) >= start && ($0.firstReviewed ?? .distantFuture) < end }.count
    }

    func fetchHighestSeenCardID() -> Int? { fetchAllCardsForReview().map(\.cardID).max() }
    func fetchReviewCount(forCardIDs ids: Set<Int>) -> Int {
        fetchAllCardsForReview().filter { ids.contains($0.cardID) }.count
    }
    func fetchDueReviewCount(forCardIDs ids: Set<Int>, at date: Date = .now) -> Int {
        fetchCardsDueForReview(at: date).filter { ids.contains($0.cardID) }.count
    }
    func fetchIgnoredCount(forCardIDs ids: Set<Int>) -> Int {
        fetchIgnoredCards().filter { ids.contains($0.cardID) }.count
    }
}
