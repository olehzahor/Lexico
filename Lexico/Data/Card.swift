//
//  Card.swift
//  Lexico
//
//  Created by user on 1/31/26.
//

import Foundation

// MARK: - Sentence

struct Sentence: Codable {
    let text: String
    let language: String
}

extension Collection where Element == Sentence {
    subscript(language: String) -> String? {
        self.first { $0.language == language }?.text
    }
}

// MARK: - Translation

struct Translation: Codable {
    let text: String
    let language: String
}

extension Collection where Element == Translation {
    subscript(language: String) -> String? {
        self.first { $0.language == language }?.text
    }
}

// MARK: - Card

struct Card: Codable, Identifiable {
    let id: Int
    let language: String = "en"
    let word: String
    let partOfSpeech: String
    let level: String
    let category: String
    let translations: [Translation]
    let sentences: [[Sentence]]

    enum CodingKeys: String, CodingKey {
        case id
        case language
        case word
        case partOfSpeech = "part_of_speech"
        case level
        case category
        case sentences
        case translations
    }
}

extension Card {
    func getRandomSentence(translation: String) -> (text: String, translation: String) {
        if let sentence = sentences.randomElement() {
            return (text: sentence[language] ?? "", translation: sentence[translation] ?? "")
        } else {
            return (text: "", translation: "")
        }
    }
    
    func getTranslation(_ language: String) -> String {
        translations.filter({ $0.language == language }).compactMap({ $0.text }).joined(separator: "; ")
    }
}
