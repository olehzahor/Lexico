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
        let word: String
        let partOfSpeech: String
        let levelBadge: String
        let categoryBadge: String
        let translation: String
        let exampleSentenceID: Int
        let exampleSentence: String
        let exampleTranslation: String
        let isNew: Bool
    }
}

extension CardView.Data {
    init(card: Card, isNew: Bool, nativeLanguage: String = "ru") {
        let sentence = card.getRandomSentence(translation: nativeLanguage)

        self.cardID = card.id
        self.word = card.word
        self.partOfSpeech = card.partOfSpeech
        self.levelBadge = card.level
        self.categoryBadge = card.localizedCategory
        self.translation = card.getTranslation(nativeLanguage)
        self.exampleSentenceID = sentence.id
        self.exampleSentence = sentence.text
        self.exampleTranslation = sentence.translation
        self.isNew = isNew
    }
}
