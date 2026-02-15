//
//  Item.swift
//  Lexico
//
//  Created by user on 12/19/25.
//

import Foundation
import SwiftData

enum CardState: Int, Codable {
    case new, learning, review
}

enum ReviewGrade: Double, Codable, CaseIterable {
    case easy, good, hard
}

@Model
final class CardProgress {
    var cardID: Int
    
    private var stateRaw: Int
    
    var state: CardState {
        get { CardState(rawValue: stateRaw) ?? .new }
        set { stateRaw = newValue.rawValue }
    }
    
    var easeFactor: Double
    var intervalDays: Int
    var reps: Int
    
    var lastReviewed: Date?
    var dueAt: Date?
    
    var ignored: Bool
    
    init(cardID: Int) {
        self.cardID = cardID
        self.stateRaw = CardState.new.rawValue
        
        self.easeFactor = 2.3
        self.intervalDays = 0
        self.reps = 0
        
        self.dueAt = Date()
        self.ignored = false
    }
}

// MARK: - Updaters
extension CardProgress {
    private var minEase: Double { 1.3 }
    private var maxEase: Double { 2.7 }

    private func clampEase(_ x: Double) -> Double {
        min(max(x, minEase), maxEase)
    }

    private func addMinutes(_ minutes: Int, to date: Date) -> Date {
        Calendar.current.date(byAdding: .minute, value: minutes, to: date) ?? date
    }

    private func addDays(_ days: Int, to date: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: date) ?? date
    }

    // MARK: - Public API
    func apply(_ grade: ReviewGrade, now: Date = .now) {
        lastReviewed = now
        reps += 1

        switch state {

        case .new:
            switch grade {
            case .hard:
                state = .learning
                dueAt = addMinutes(1, to: now)

            case .good:
                state = .learning
                dueAt = addDays(1, to: now)

            case .easy:
                state = .review
                intervalDays = 3
                dueAt = addDays(intervalDays, to: now)
            }

        case .learning:
            switch grade {
            case .hard:
                dueAt = addMinutes(10, to: now)

            case .good:
                dueAt = addDays(1, to: now)

            case .easy:
                state = .review
                intervalDays = max(intervalDays, 3)
                dueAt = addDays(intervalDays, to: now)
            }

        case .review:
            var newEase = easeFactor
            var newInterval = max(1, intervalDays)

            switch grade {
            case .hard:
                newEase = clampEase(newEase - 0.15)
                newInterval = max(1, Int((Double(newInterval) * 1.2).rounded()))

            case .good:
                newInterval = max(1, Int((Double(newInterval) * newEase).rounded()))

            case .easy:
                newEase = clampEase(newEase + 0.05)
                newInterval = max(1, Int((Double(newInterval) * (newEase + 0.15)).rounded()))
            }

            easeFactor = newEase
            intervalDays = newInterval
            dueAt = addDays(intervalDays, to: now)
        }
    }

    func setIgnored(_ ignored: Bool) {
        self.ignored = ignored
    }
}

// MARK: - Predicates
extension CardProgress {
    static func allCardsForReviewFilter() -> Predicate<CardProgress> {
        let learningState = CardState.learning.rawValue
        let reviewState = CardState.review.rawValue
        return #Predicate<CardProgress> { progress in
            progress.ignored == false &&
            (progress.stateRaw == learningState || progress.stateRaw == reviewState)
        }
    }
    
    static func cardsDueForReviewFilter(at date: Date) -> Predicate<CardProgress> {
        let learningState = CardState.learning.rawValue
        let reviewState = CardState.review.rawValue
        return #Predicate<CardProgress> { progress in
            progress.ignored == false &&
            (progress.stateRaw == learningState || progress.stateRaw == reviewState) &&
            progress.dueAt != nil &&
            progress.dueAt! <= date
        }
    }

    static func reviewCardsFilter(forCardIDs cardIDs: [Int]) -> Predicate<CardProgress> {
        let learningState = CardState.learning.rawValue
        let reviewState = CardState.review.rawValue
        return #Predicate<CardProgress> { progress in
            cardIDs.contains(progress.cardID) &&
            progress.ignored == false &&
            (progress.stateRaw == learningState || progress.stateRaw == reviewState)
        }
    }

    static func dueReviewCardsFilter(forCardIDs cardIDs: [Int], at date: Date) -> Predicate<CardProgress> {
        let learningState = CardState.learning.rawValue
        let reviewState = CardState.review.rawValue
        return #Predicate<CardProgress> { progress in
            cardIDs.contains(progress.cardID) &&
            progress.ignored == false &&
            (progress.stateRaw == learningState || progress.stateRaw == reviewState) &&
            progress.dueAt != nil &&
            progress.dueAt! <= date
        }
    }
}
