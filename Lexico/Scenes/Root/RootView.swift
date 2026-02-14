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
            SessionView(cardsProvider: cardsProvider, progressTracker: progressTracker)
                .tabItem {
                    Label("Session", systemImage: "house")
                }

            CardsView(cardsProvider: cardsProvider, progressTracker: progressTracker)
                .tabItem {
                    Label("Cards", systemImage: "square.stack.3d.up")
                }
        }
    }

    init(cardsProvider: CardsProvider, progressTracker: CardsProgressTracker) {
        self.cardsProvider = cardsProvider
        self.progressTracker = progressTracker
    }
}
