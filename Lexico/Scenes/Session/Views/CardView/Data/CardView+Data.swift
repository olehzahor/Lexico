//
//  CardView+Data.swift
//  Lexico
//
//  Created by Codex on 2/15/26.
//

import Foundation

extension CardView {
    struct Data {
        let cardID: Int
        let title: String
        let subtitle: String
        let levelBadge: String
        let categoryBadge: String
        let translation: String
        let exampleSentence: String
        let exampleTranslation: String
        let isNew: Bool
    }
}

extension CardView.Data {
    init(card: Card, isNew: Bool, nativeLanguage: String = "ru") {
        let sentence = card.getRandomSentence(translation: nativeLanguage)

        self.cardID = card.id
        self.title = card.word
        self.subtitle = card.partOfSpeech
        self.levelBadge = card.level
        self.categoryBadge = card.category
        self.translation = card.getTranslation(nativeLanguage)
        self.exampleSentence = sentence.text
        self.exampleTranslation = sentence.translation
        self.isNew = isNew
    }
}
