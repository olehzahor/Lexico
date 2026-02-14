//
//  CardsRowView+Data.swift
//  Lexico
//
//  Created by Codex on 2/14/26.
//

import Foundation

extension CardsRowView {
    struct Data {
        let id: String
        let cardID: Int
        let word: String
        let meta: String
        let status: String?
        let dueAt: Date?

        init(card: Card, status: String?) {
            self.id = "card-\(card.id)"
            self.cardID = card.id
            self.word = card.word
            self.meta = "\(card.level) · \(card.category)"
            self.status = status
            self.dueAt = nil
        }

        init(reviewItem: ReviewQueueItem) {
            self.id = "review-\(reviewItem.card.id)"
            self.cardID = reviewItem.card.id
            self.word = reviewItem.card.word
            self.meta = "\(reviewItem.card.level) · \(reviewItem.card.category)"
            self.status = nil
            self.dueAt = reviewItem.dueAt
        }
    }
}

extension CardsRowView.Data: Identifiable {}
