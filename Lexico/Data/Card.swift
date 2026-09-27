//
//  Card.swift
//  Lexico
//
//  Created by user on 1/31/26.
//

import Foundation

// MARK: - Sentence

struct SentenceSet: Codable {
    let id: Int
    let sentences: [Sentence]
}

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
    // Filled from the deck's top-level categories after decoding.
    var categoryNames: [String: String] = [:]
    let translations: [Translation]
    let sentences: [SentenceSet]

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
    var localizedCategory: String {
        let language = Bundle.main.preferredLocalizations.first ?? "en"
        return categoryName(for: language)
    }

    func categoryName(for language: String) -> String {
        let code = String(language.split(separator: "-").first ?? "en")
        return categoryNames[code] ?? categoryNames["en"] ?? category
    }
    
    func getRandomSentence(translation: String) -> (id: Int, text: String, translation: String) {
        if let sentence = sentences.randomElement() {
            return (id: sentence.id, text: sentence.sentences[language] ?? "", translation: sentence.sentences[translation] ?? "")
        } else {
            return (id: 0, text: "", translation: "")
        }
    }
    
    func getTranslation(_ language: String) -> String {
        translations.filter({ $0.language == language }).compactMap({ $0.text }).joined(separator: "; ")
    }
}
