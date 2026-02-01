//
//  ContentView.swift
//  Lexico
//
//  Created by user on 12/19/25.
//

import SwiftUI
import SwiftData

struct CardView: View {
    let nativeLanguage: String = "ru"

    var data: Card
    @State var isFlipped: Bool = false
    
    var onComplete: () -> Void
    
    private func complete() {
        isFlipped = false
        onComplete()
    }
    
    @ViewBuilder
    var defaultState: some View {
        VStack {
            HStack {
                Spacer()
                Text(data.category)
                    .fontDesign(.serif)
                Spacer()
                Text("🗣️")
                    .font(.system(size: 40))
                    .onTapGesture {
                    }
            }
            .padding()
            Spacer()
            Text(data.word)
                .fontDesign(.serif)
                .font(.largeTitle)
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
        let sentence = data.getRandomSentence(translation: nativeLanguage)
        VStack {
            HStack {
                Spacer()
                Text(data.category)
                Spacer()
                Text("🗣️")
                    .font(.system(size: 40))
                    .onTapGesture {
                    }
            }
            .padding()
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
                    complete()
                } label: {
                    Text("Easy")
                }

                Button {
                    complete()
                } label: {
                    Text("Good")
                }
                
                Button {
                    complete()
                } label: {
                    Text("Hard")
                }
            }
            .padding(.vertical)
        }
        .multilineTextAlignment(.center)
        .padding()
    }
    
    var body: some View {
        ZStack {
            Color.white
            Group {
                if isFlipped {
                    flippedState
                } else {
                    defaultState
                }
            }
            .contentShape(.rect)
        }
        .onTapGesture {
            isFlipped.toggle()
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct ContentView: View {
    let cards: [Card]
    @State var activeCard: Card
    
    var body: some View {
        CardView(data: activeCard) {
            activeCard = cards.randomElement()!
        }
        .padding()
        .background(Color.gray)
    }
    
    init(cards: [Card]) {
        self.cards = cards
        self.activeCard = cards.randomElement()!
    }
}

#Preview {
    let cardsProvider = CardsProvider()
    ContentView(cards: cardsProvider.getAllCards(for: "en"))
}
