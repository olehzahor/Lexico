//
//  CardsProvider.swift
//  Lexico
//
//  Created by user on 2/1/26.
//

import Foundation

struct CardsResponse: Codable {
    let words: [Card]
}

struct CardsProvider {
    private static let jsonDecoder = JSONDecoder()
    
    func getAllCards(for lang: String) -> [Card] {
        guard let url = Bundle.main.url(forResource: "cards_\(lang)", withExtension: "json") else {
            print("⚠️ Could not find cards_\(lang).json")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let response = try Self.jsonDecoder.decode(CardsResponse.self, from: data)
            return response.words
        } catch {
            print("⚠️ Error loading cards: \(error)")
            return []
        }
    }
}
