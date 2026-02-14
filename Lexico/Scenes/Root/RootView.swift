//
//  RootView.swift
//  Lexico
//
//  Created by Codex on 2/9/26.
//

import SwiftUI

struct RootView: View {
    private let cardsProvider: CardsProvider
    private let progressTracker: CardsProgressTracker

    var body: some View {
        TabView {
            DeckView(cardsProvider: cardsProvider, progressTracker: progressTracker)
                .tabItem {
                    Label("Дека", systemImage: "square.stack.3d.up")
                }

            QueueView(cardsProvider: cardsProvider, progressTracker: progressTracker)
                .tabItem {
                    Label("Ревью", systemImage: "clock")
                }
        }
    }

    init(cardsProvider: CardsProvider, progressTracker: CardsProgressTracker) {
        self.cardsProvider = cardsProvider
        self.progressTracker = progressTracker
    }
}
