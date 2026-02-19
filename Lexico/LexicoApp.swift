//
//  LexicoApp.swift
//  Lexico
//
//  Created by user on 12/19/25.
//

import SwiftUI
import SwiftData

@main
struct LexicoApp: App {    
    @AppStorage("didSeedInitialIgnoredCards")
    private var didSeedInitialIgnoredCards: Bool = false

    private var cardsProgressTracker: CardsProgressTracker
    private var cardsProvider: CardsProvider
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CardProgress.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView(cardsProvider: cardsProvider, progressTracker: cardsProgressTracker)
        }
        .modelContainer(sharedModelContainer)
    }
    
    init() {
        self.cardsProgressTracker = CardsProgressTracker(modelContext: sharedModelContainer.mainContext)
        self.cardsProvider = CardsProvider(progressManager: cardsProgressTracker)

        if !didSeedInitialIgnoredCards {
            for i in 0..<92 {
                cardsProgressTracker.ignoreCard(cardID: i, ignored: true)
            }
            didSeedInitialIgnoredCards = true
        }
    }
}
