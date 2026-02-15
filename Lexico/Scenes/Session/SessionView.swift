//
//  SessionView.swift
//  Lexico
//
//  Created by user on 2/9/26.
//

import SwiftUI
import SwiftData

struct SessionView: View {
    @State private var viewModel: SessionViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBg.ignoresSafeArea()

                if let activeCard = viewModel.activeCard {
                    CardView(data: activeCard, isNew: viewModel.isActiveCardNew) { action in
                        viewModel.handleCardAction(action, for: activeCard)
                    }
                    .padding()
                } else {
                    ContentUnavailableView(
                        "You're all caught up",
                        systemImage: "checkmark.circle",
                        description: Text("No cards are available right now. Come back later for more reviews.")
                    )
                    .foregroundStyle(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    SessionMetricsHeaderView(
                        goalText: "Today’s goal: \(viewModel.todayReviewsCount)/\(viewModel.dailyGoal)",
                        completionText: viewModel.currentLevelTitle
                    )
                }
            }
        }
        .onAppear {
            viewModel.refresh()
        }
    }
    
    init(
        cardsProvider: any CardsProviding,
        progressTracker: CardsProgressTracker
    ) {
        let metricsService = SessionMetricsService(
            progressTracker: progressTracker,
            cardsProvider: cardsProvider
        )

        _viewModel = State(
            initialValue: SessionViewModel(
                cardsProvider: cardsProvider,
                progressTracker: progressTracker,
                metricsService: metricsService
            )
        )
    }
}

private struct SessionMetricsHeaderView: View {
    let goalText: String
    let completionText: String

    var body: some View {
        VStack(spacing: 2) {
            Text(goalText)
                .font(.caption)
                .foregroundStyle(.white)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Text(completionText)
                .font(.caption2)
                .foregroundStyle(.gray)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CardProgress.self, configurations: config)
    let progressTracker = CardsProgressTracker(modelContext: container.mainContext)
    let cardsProvider = CardsProvider(progressManager: progressTracker)

    SessionView(cardsProvider: cardsProvider, progressTracker: progressTracker)
        .modelContainer(container)
}

#Preview("Empty Session") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CardProgress.self, configurations: config)
    let progressTracker = CardsProgressTracker(modelContext: container.mainContext)
    let cardsProvider = CardsProvider(
        progressManager: progressTracker,
        dataSource: EmptyCardsDataSource()
    )

    return SessionView(cardsProvider: cardsProvider, progressTracker: progressTracker)
        .modelContainer(container)
}
