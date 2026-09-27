//
//  BundleCardsDataSource.swift
//  Lexico
//
//  Created by Codex on 2/15/26.
//

import Foundation

struct BundleCardsDataSource: CardsDataSource {
    private static let jsonDecoder = JSONDecoder()
    private let filePrefix: String?

    init(filePrefix: String? = nil) { self.filePrefix = filePrefix }

    static func availableDecks() -> [Deck] {
        let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
        return urls.compactMap { url in
            guard url.deletingPathExtension().lastPathComponent.hasSuffix("_en"),
                  !url.lastPathComponent.hasPrefix("example_"),
                  let data = try? Data(contentsOf: url),
                  let metadata = try? jsonDecoder.decode(DeckMetadataResponse.self, from: data) else { return nil }
            return metadata.metadata.deck
        }.sorted { $0.id < $1.id }
    }

    func fetchCards(for lang: String, deckID: String) -> [Card] {
        let prefix = filePrefix ?? (deckID == "default" ? "cards" : deckID)
        guard let url = Bundle.main.url(forResource: "\(prefix)_\(lang)", withExtension: "json") else {
            print("⚠️ Could not find \(prefix)_\(lang).json")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let response = try Self.jsonDecoder.decode(CardsResponse.self, from: data)
            return response.words.map { card in
                var card = card
                card.categoryNames = response.categories[card.category] ?? [:]
                return card
            }
        } catch {
            print("⚠️ Error loading cards: \(error)")
            return []
        }
    }
}

private extension BundleCardsDataSource {
    struct DeckMetadataResponse: Decodable { let metadata: Metadata }
    struct Metadata: Decodable { let deck: Deck }
    struct CardsResponse: Codable {
        let categories: [String: [String: String]]
        let words: [Card]
    }
}
