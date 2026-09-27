//
//  CardHistory.swift
//  Lexico
//
//  Created by user on 1/31/26.
//

import SwiftData
import Foundation

@Model
final class CardHistory {
    var cardID: Int
    var deckID: String?
    var progress: CardProgress
    var date: Date
    
    init(cardID: Int, progress: CardProgress, date: Date) {
        self.cardID = cardID
        self.deckID = progress.deckID ?? "default"
        self.progress = progress
        self.date = date
    }
}
