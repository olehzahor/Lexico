//
//  CardsProgressTrackerProtocol.swift
//  Lexico
//
//  Created by user on 2/15/26.
//

import Foundation

@MainActor
protocol CardsProgressTrackerProtocol: AnyObject {
    var progressChanges: AsyncStream<Void> { get }

    func reviewCard(cardID: Int, grade: ReviewGrade, at date: Date)
    func ignoreCard(cardID: Int, ignored: Bool)
    func getAllProgress() -> [CardProgress]
    func getProgress(for cardID: Int) -> CardProgress
    func getProgressIfExists(for cardID: Int) -> CardProgress?
}

extension CardsProgressTracker: CardsProgressTrackerProtocol {}
