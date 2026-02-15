//
//  CardView.swift
//  Lexico
//
//  Created by user on 2/14/26.
//

import SwiftUI

struct CardView: View {
    enum UserAction {
        case easy
        case good
        case hard
        case ignore
    }

    let nativeLanguage: String = "ru"
    let sentence: (text: String, translation: String)
    
    var data: Card
    let isNew: Bool
    @State var isFlipped: Bool = false
    
    var onAction: (UserAction) -> Void
    
    private func complete(with action: UserAction) {
        isFlipped = false
        onAction(action)
    }
    
    private var bgColor: Color {
        isNew ? .newCardBg : .reviewCardBg
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
                    complete(with: .ignore)
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
                    complete(with: .easy)
                } label: {
                    Text("Easy")
                }

                Button {
                    complete(with: .good)
                } label: {
                    Text("Good")
                }
                
                Button {
                    complete(with: .hard)
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
    
    init(data: Card, isNew: Bool, onAction: @escaping (UserAction) -> Void) {
        self.data = data
        self.isNew = isNew
        self.onAction = onAction
        self.sentence = data.getRandomSentence(translation: nativeLanguage)
    }
}
