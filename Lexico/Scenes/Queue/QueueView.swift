//
//  ReviewQueueView.swift
//  Lexico
//
//  Created by Codex on 2/9/26.
//

import SwiftUI
import SwiftData

struct QueueView: View {
    private let cardsProvider: CardsProvider

    @Query(sort: \CardProgress.dueAt, order: .forward)
    private var allProgress: [CardProgress]

    private var cardsByID: [Int: Card] {
        Dictionary(uniqueKeysWithValues: cardsProvider.getAllCards(for: "en").map { ($0.id, $0) })
    }

    private var upcoming: [(card: Card, dueAt: Date)] {
        let now = Date.now
        return allProgress.compactMap { p in
            guard p.ignored == false else { return nil }
            guard p.state != .new else { return nil }
            guard let dueAt = p.dueAt else { return nil }
            guard dueAt > now else { return nil }
            guard let card = cardsByID[p.cardID] else { return nil }
            return (card: card, dueAt: dueAt)
        }
        .sorted { $0.dueAt < $1.dueAt }
    }

    var body: some View {
        NavigationStack {
            List {
                if upcoming.isEmpty {
                    ContentUnavailableView(
                        "Нет карточек в ожидании",
                        systemImage: "clock",
                        description: Text("Карточки появятся здесь после прохождения ревью.")
                    )
                } else {
                    Section("Скоро будут доступны") {
                        ForEach(upcoming, id: \.card.id) { item in
                            ReviewQueueRow(card: item.card, dueAt: item.dueAt)
                        }
                    }
                }
            }
            .navigationTitle("Ревью")
        }
    }

    init(cardsProvider: CardsProvider) {
        self.cardsProvider = cardsProvider
    }
}

private struct ReviewQueueRow: View {
    let card: Card
    let dueAt: Date

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(card.word)
                    .font(.headline)
                Text(card.category)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(dueAt, style: .relative)
                    .font(.subheadline)
                    .monospacedDigit()
                Text(dueAt, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
    }
}

