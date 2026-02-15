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
    private var progressChangesContinuation: AsyncStream<Void>.Continuation?
    lazy var progressChanges: AsyncStream<Void> = {
        AsyncStream { [weak self] continuation in
            self?.progressChangesContinuation = continuation
        }
    }()

    // MARK: - Lifecycle
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - CardsProgressTracking
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

    // MARK: - CardsProgressTracking (Read)
    func getAllProgress() -> [CardProgress] {
        let descriptor = FetchDescriptor<CardProgress>()
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func getProgress(for cardID: Int) -> CardProgress {
        let predicate = #Predicate<CardProgress> { $0.cardID == cardID }
        let descriptor = FetchDescriptor(predicate: predicate)

        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }

        let newProgress = CardProgress(cardID: cardID)
        modelContext.insert(newProgress)
        return newProgress
    }
    
    func getProgressIfExists(for cardID: Int) -> CardProgress? {
        let predicate = #Predicate<CardProgress> { $0.cardID == cardID }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try? modelContext.fetch(descriptor).first
    }

    // MARK: - CardsProviderProgressReading
    func fetchIgnoredCards() -> [CardProgress] {
        let predicate = #Predicate<CardProgress> { $0.ignored == true }
        let descriptor = FetchDescriptor(predicate: predicate)
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchAllCardsForReview() -> [CardProgress] {
        let descriptor = FetchDescriptor(predicate: CardProgress.allCardsForReviewFilter())
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchCardsDueForReview(at date: Date) -> [CardProgress] {
        let descriptor = FetchDescriptor(predicate: CardProgress.cardsDueForReviewFilter(at: date))
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    // MARK: - SessionMetricsProgressReading
    func fetchReviewedTodayCount(now: Date = .now) -> Int {
        let calendar = Calendar.autoupdatingCurrent
        let dayStart = calendar.startOfDay(for: now)
        let nextDayStart = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? now

        let predicate = #Predicate<CardProgress> { progress in
            progress.lastReviewed != nil &&
            progress.lastReviewed! >= dayStart &&
            progress.lastReviewed! < nextDayStart
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        return (try? modelContext.fetch(descriptor).count) ?? 0
    }

    func fetchHighestSeenCardID() -> Int? {
        var descriptor = FetchDescriptor<CardProgress>(
            predicate: CardProgress.allCardsForReviewFilter(),
            sortBy: [SortDescriptor(\.cardID, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first?.cardID
    }

    func fetchReviewCount(forCardIDs cardIDs: Set<Int>) -> Int {
        guard cardIDs.isEmpty == false else { return 0 }

        let ids = Array(cardIDs)
        let predicate = CardProgress.reviewCardsFilter(forCardIDs: ids)
        let descriptor = FetchDescriptor(predicate: predicate)
        return (try? modelContext.fetch(descriptor).count) ?? 0
    }

    func fetchDueReviewCount(forCardIDs cardIDs: Set<Int>, at date: Date = .now) -> Int {
        guard cardIDs.isEmpty == false else { return 0 }

        let ids = Array(cardIDs)
        let predicate = CardProgress.dueReviewCardsFilter(forCardIDs: ids, at: date)
        let descriptor = FetchDescriptor(predicate: predicate)
        return (try? modelContext.fetch(descriptor).count) ?? 0
    }

    func fetchIgnoredCount(forCardIDs cardIDs: Set<Int>) -> Int {
        guard cardIDs.isEmpty == false else { return 0 }

        let ids = Array(cardIDs)
        let predicate = #Predicate<CardProgress> { progress in
            ids.contains(progress.cardID) && progress.ignored == true
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        return (try? modelContext.fetch(descriptor).count) ?? 0
    }
}
