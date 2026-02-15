//
//  CardsView.swift
//  Lexico
//
//  Created by Codex on 2/9/26.
//

import SwiftUI
import SwiftData

struct CardsView: View {
    @State private var viewModel: CardsViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker(
                        "Cards filter",
                        selection: $viewModel.activeFilter
                    ) {
                        ForEach(CardsViewModel.CardsFilter.allCases) { f in
                            Text(f.title).tag(f)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
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
                            CardsRowView(data: item)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    if viewModel.activeFilter == .ignored {
                                        Button {
                                            viewModel.setIgnored(false, for: item)
                                        } label: {
                                            Label("Unignore", systemImage: "arrow.uturn.backward")
                                        }
                                        .tint(.blue)
                                    } else {
                                        Button(role: .destructive) {
                                            viewModel.setIgnored(true, for: item)
                                        } label: {
                                            Label("Ignore", systemImage: "eye.slash")
                                        }
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle("Cards")
        }
        .onAppear {
            viewModel.reload()
        }
    }

    init(cardsProvider: any CardsProviding, progressTracker: CardsProgressTracking) {
        _viewModel = State(initialValue: CardsViewModel(cardsProvider: cardsProvider, progressTracker: progressTracker))
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
    
    return CardsView(cardsProvider: cardsProvider, progressTracker: progressTracker)
        .modelContainer(container)
}
