//
//  DeckView.swift
//  Lexico
//
//  Created by user on 2/9/26.
//

import SwiftUI
import SwiftData

struct BadgeView: View {
    var text: String?
    
    var body: some View {
        if let text {
            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background {
                    Capsule().fill(Color.blue)
                }
        }
    }
}

struct CardView: View {
    let nativeLanguage: String = "ru"
    let sentence: (text: String, translation: String)

    private let progressTracker: CardsProgressTracker
    
    var data: Card
    @State var isFlipped: Bool = false
    
    var onComplete: () -> Void
    
    private func complete() {
        isFlipped = false
        onComplete()
    }
    
    private var bgColor: Color {
        let progress = progressTracker.getProgress(for: data.id)
        return progress.state == .new ? .newCardBg : .reviewCardBg
    }
    
    @ViewBuilder
    var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Spacer()
            BadgeView(text: data.level)
            BadgeView(text: data.category)
            Spacer()
        }
    }
    
    @ViewBuilder
    var defaultState: some View {
        VStack {
            header
            Spacer()
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(data.word)
                    .fontDesign(.serif)
                    .font(.largeTitle)
            }
            Text(data.partOfSpeech)
                .fontDesign(.serif)
                .font(.headline)
                .fontWeight(.thin)
                .foregroundStyle(Color.secondary)

            Spacer()
            
            HStack(spacing: 32) {
                Button {
                    
                } label: {
                    Text("Ignore")
                }
            }
            .padding(.vertical)
        }
    }
    
    @ViewBuilder
    var flippedState: some View {
        VStack {
            header
            Spacer()
            Text(data.getTranslation(nativeLanguage))
                .fontDesign(.serif)
                .font(.largeTitle)
            Text(data.word)
                .fontDesign(.serif)
                .foregroundStyle(Color.secondary)
                .font(.headline)
            Text(data.partOfSpeech)
                .fontDesign(.serif)
                .font(.headline)
                .fontWeight(.thin)
                .foregroundStyle(Color.secondary)
            
            Divider().padding(.vertical)
            
            Text(sentence.text)
                .fontDesign(.serif)
                .italic()
                .font(.title2)
                .padding(.vertical)
            Text(sentence.translation)
                .fontDesign(.serif)
                .foregroundStyle(Color.secondary)
                .font(.default)

            Spacer()
            
            HStack(spacing: 32) {
                Button {
                    progressTracker.reviewCard(cardID: data.id, grade: .easy)
                    complete()
                } label: {
                    Text("Easy")
                }

                Button {
                    progressTracker.reviewCard(cardID: data.id, grade: .good)
                    complete()
                } label: {
                    Text("Good")
                }
                
                Button {
                    progressTracker.reviewCard(cardID: data.id, grade: .hard)
                    complete()
                } label: {
                    Text("Hard")
                }
            }
            .padding(.vertical)
        }
        .multilineTextAlignment(.center)
    }
    
    var body: some View {
        ZStack {
            bgColor
            ZStack {
                if isFlipped {
                    flippedState
                } else {
                    defaultState
                }
            }
            .padding()
            .transition(.opacity)
            .animation(.bouncy, value: isFlipped)
            .contentShape(.rect)
        }
        .onTapGesture {
            isFlipped.toggle()
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    init(data: Card, progressTracker: CardsProgressTracker, onComplete: @escaping () -> Void) {
        self.data = data
        self.onComplete = onComplete
        self.sentence = data.getRandomSentence(translation: nativeLanguage)
        self.progressTracker = progressTracker
    }
}



struct DeckView: View {
    private let cardsProvider: CardsProvider
    private let progressTracker: CardsProgressTracker
    
    @State var activeCard: Card?
    
    var body: some View {
        if let activeCard {
            CardView(data: activeCard, progressTracker: progressTracker) {
                self.activeCard = cardsProvider.getNextCard(for: "en")
            }
            .padding()
            .background(Color.appBg)
        } else {
            Text("no cards :(")
        }
    }
    
    init(cardsProvider: CardsProvider, progressTracker: CardsProgressTracker) {
        self.cardsProvider = cardsProvider
        self.progressTracker = progressTracker
        self._activeCard = State(initialValue: cardsProvider.getNextCard(for: "en"))
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CardProgress.self, configurations: config)
    let progressTracker = CardsProgressTracker(modelContext: container.mainContext)
    let cardsProvider = CardsProvider(progressManager: progressTracker)

    DeckView(cardsProvider: cardsProvider, progressTracker: progressTracker)
        .modelContainer(container)
}
