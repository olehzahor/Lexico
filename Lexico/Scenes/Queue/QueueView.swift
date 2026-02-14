//
//  ReviewQueueView.swift
//  Lexico
//
//  Created by Codex on 2/9/26.
//

import SwiftUI
import SwiftData

struct QueueView: View {
    @State private var viewModel: QueueViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker(
                        "Queue filter",
                        selection: $viewModel.activeFilter
                    ) {
                        ForEach(QueueViewModel.QueueFilter.allCases) { f in
                            Text(f.title).tag(f)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                Section {
                    if viewModel.isEmpty {
                        ContentUnavailableView(
                            viewModel.emptyState.title,
                            systemImage: viewModel.emptyState.systemImage,
                            description: Text(viewModel.emptyState.description)
                        )
                    } else {
                        ForEach(viewModel.items) { item in
                            QueueRowView(data: item)
                        }
                    }
                }
            }
            .navigationTitle("Review Queue")
        }
        .onAppear {
            viewModel.reload()
        }
    }

    init(cardsProvider: CardsProvider) {
        _viewModel = State(initialValue: QueueViewModel(cardsProvider: cardsProvider))
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
