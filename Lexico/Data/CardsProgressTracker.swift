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

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Private helpers

    private func getProgress(for cardID: Int) -> CardProgress {
        let predicate = #Predicate<CardProgress> { $0.cardID == cardID }
        let descriptor = FetchDescriptor(predicate: predicate)

        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }

        let newProgress = CardProgress(cardID: cardID)
        modelContext.insert(newProgress)
        return newProgress
    }

    // MARK: - Public API

    func reviewCard(cardID: Int, grade: ReviewGrade, at date: Date = .now) {
        let progress = getProgress(for: cardID)
        progress.apply(grade, now: date)
        try? modelContext.save()
    }

    func ignoreCard(cardID: Int, ignored: Bool) {
        let progress = getProgress(for: cardID)
        progress.setIgnored(ignored)
        try? modelContext.save()
    }

    func getAllProgress() -> [CardProgress] {
        let descriptor = FetchDescriptor<CardProgress>()
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func getProgressIfExists(for cardID: Int) -> CardProgress? {
        let predicate = #Predicate<CardProgress> { $0.cardID == cardID }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try? modelContext.fetch(descriptor).first
    }
}
