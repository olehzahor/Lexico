//
//  ReviewQueueItem.swift
//  Lexico
//
//  Created by user on 2/9/26.
//

import Foundation

struct ReviewQueueItem {
    let card: Card
    
    var state: CardState
    var reps: Int
    
    var lastReviewed: Date?
    var dueAt: Date?
}

extension ReviewQueueItem {
    init(card: Card, progress: CardProgress) {
        self.card = card
        self.state = progress.state
        self.reps = progress.reps
        self.lastReviewed = progress.lastReviewed
        self.dueAt = progress.dueAt
    }
}
