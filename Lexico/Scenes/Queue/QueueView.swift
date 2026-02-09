//
//  ReviewQueueView.swift
//  Lexico
//
//  Created by Codex on 2/9/26.
//

import SwiftUI
import SwiftData

private struct ReviewQueueRow: View {
    let item: ReviewQueueItem

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let now = context.date
            let isReady = LexicoDateTimeFormatter.isReady(dueAt: item.dueAt, now: now)

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.card.word)
                        .font(.headline)
                    Text("\(item.card.level) · \(item.card.category)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    if isReady {
                        Text(LexicoDateTimeFormatter.readyText)
                            .font(.subheadline)
                            .monospacedDigit()
                    } else if let dueAt = item.dueAt {
                        Text(dueAt, style: .relative)
                            .font(.subheadline)
                            .monospacedDigit()
                    }

                    if let dueAt = item.dueAt {
                        Text(LexicoDateTimeFormatter.dayTimeLabel(for: dueAt, now: now))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }
            }
        }
    }
}

struct QueueView: View {
    private let cardsProvider: CardsProvider

    private var queue: [ReviewQueueItem] {
        cardsProvider.getReviewQueue(for: "en")
    }
    
    var body: some View {
        NavigationStack {
            List {
                if queue.isEmpty {
                    ContentUnavailableView(
                        "Нет карточек в ожидании",
                        systemImage: "clock",
                        description: Text("Карточки появятся здесь после прохождения ревью.")
                    )
                } else {
                    Section {
                        ForEach(queue, id: \.card.id) { item in
                            ReviewQueueRow(item: item)
                        }
                    }
                }
            }
            .navigationTitle("Review Queue")
        }
    }

    init(cardsProvider: CardsProvider) {
        self.cardsProvider = cardsProvider
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CardProgress.self, configurations: config)
    let progressTracker = CardsProgressTracker(modelContext: container.mainContext)
    let cardsProvider = CardsProvider(progressManager: progressTracker)

    let cards = cardsProvider.getAllCards(for: "en").prefix(5)
    for card in cards {
        progressTracker.reviewCard(cardID: card.id, grade: ReviewGrade.allCases.randomElement()!, at: .now)
    }
    
    return QueueView(cardsProvider: cardsProvider)
        .modelContainer(container)
}
