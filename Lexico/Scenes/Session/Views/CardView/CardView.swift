//
//  CardView.swift
//  Lexico
//
//  Created by user on 2/14/26.
//

import SwiftUI

struct CardView: View {
    var data: Data
    @State var isFlipped: Bool = false
    
    var onAction: (UserAction) -> Void
        
    private var bgColor: Color {
        data.isNew ? .newCardBg : .reviewCardBg
    }

    private func complete(with action: UserAction) {
        isFlipped = false
        onAction(action)
    }

    @ViewBuilder
    private func completionButton(bgColor: Color? = nil, _ action: UserAction) -> some View {
        let style = bgColor.map { AppButtonView.Style.default.with(bgColor: $0) } ?? .default
        AppButtonView(title: action.title, style: style) {
            complete(with: action)
        }
    }
    
    @ViewBuilder
    var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Spacer()
            BadgeView(text: data.levelBadge)
            BadgeView(text: data.categoryBadge)
            Spacer()
        }
    }
    
    @ViewBuilder
    var defaultState: some View {
        VStack {
            header
            Spacer()
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(data.title)
                    .fontDesign(.serif)
                    .font(.largeTitle)
            }
            Text(data.subtitle)
                .fontDesign(.serif)
                .font(.headline)
                .fontWeight(.thin)
                .foregroundStyle(Color.secondary)

            Spacer()
            
            HStack(spacing: 32) {
                completionButton(bgColor: .red, .ignore)
            }
            .padding(.vertical)
        }
    }
    
    @ViewBuilder
    var flippedState: some View {
        VStack {
            header
            Spacer()
            Text(data.translation)
                .fontDesign(.serif)
                .font(.largeTitle)
            Text(data.title)
                .fontDesign(.serif)
                .foregroundStyle(Color.secondary)
                .font(.headline)
            Text(data.subtitle)
                .fontDesign(.serif)
                .font(.headline)
                .fontWeight(.thin)
                .foregroundStyle(Color.secondary)
            
            Divider().padding(.vertical)
            
            Text(data.exampleSentence)
                .fontDesign(.serif)
                .italic()
                .font(.title2)
                .padding(.vertical)
            Text(data.exampleTranslation)
                .fontDesign(.serif)
                .foregroundStyle(Color.secondary)
                .font(.default)

            Spacer()
            
            HStack(spacing: 32) {
                completionButton(bgColor: .green, .easy)
                completionButton(.good)
                completionButton(bgColor: .orange, .hard)
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
    
    init(data: Data, onAction: @escaping (UserAction) -> Void) {
        self.data = data
        self.onAction = onAction
    }
}

#Preview("New Card") {
    ZStack {
        Color.appBg.ignoresSafeArea()
        CardView(
            data: .init(
                cardID: 1,
                title: "benevolent",
                subtitle: "adjective",
                levelBadge: "B2",
                categoryBadge: "Personality",
                translation: "доброжелательный",
                exampleSentence: "She remained benevolent even in difficult negotiations.",
                exampleTranslation: "Она оставалась доброжелательной даже в сложных переговорах.",
                isNew: true
            ),
            onAction: { _ in }
        )
        .padding()
    }
}

#Preview("Review Card") {
    ZStack {
        Color.appBg.ignoresSafeArea()
        CardView(
            data: .init(
                cardID: 42,
                title: "convey",
                subtitle: "verb",
                levelBadge: "B1",
                categoryBadge: "Communication",
                translation: "передавать; выражать",
                exampleSentence: "The report conveys the main risks clearly.",
                exampleTranslation: "Отчёт ясно передаёт основные риски.",
                isNew: false
            ),
            onAction: { _ in }
        )
        .padding()
    }
}
