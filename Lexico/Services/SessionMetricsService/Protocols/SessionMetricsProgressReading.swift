//
//  SessionMetricsProgressReading.swift
//  Lexico
//
//  Created by user on 2/15/26.
//

import Foundation

@MainActor
protocol SessionMetricsProgressReading: AnyObject {
    func fetchReviewedTodayCount(now: Date) -> Int
    func fetchHighestSeenCardID() -> Int?
    func fetchReviewCount(forCardIDs cardIDs: Set<Int>) -> Int
    func fetchDueReviewCount(forCardIDs cardIDs: Set<Int>, at date: Date) -> Int
    func fetchIgnoredCount(forCardIDs cardIDs: Set<Int>) -> Int
}

extension CardsProgressTracker: SessionMetricsProgressReading {}
