//
//  CardFlipView.swift
//  Lexico
//
//  Created by Codex on 2/15/26.
//

import SwiftUI

struct CardFlipView<Front: View, Back: View>: View {
    @Binding var isFlipped: Bool
    let duration: Double
    let front: Front
    let back: Back

    private var animation: Animation {
        .linear(duration: duration)
    }

    var body: some View {
        ZStack {
            front
                .rotation3DEffect(
                    .degrees(isFlipped ? -90 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
                .animation(isFlipped ? animation : animation.delay(duration), value: isFlipped)

            back
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : 90),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
                .animation(isFlipped ? animation.delay(duration) : animation, value: isFlipped)
        }
        .contentShape(.rect)
        .compositingGroup()
    }

    init(
        isFlipped: Binding<Bool>,
        duration: Double,
        @ViewBuilder front: () -> Front,
        @ViewBuilder back: () -> Back
    ) {
        self._isFlipped = isFlipped
        self.duration = duration
        self.front = front()
        self.back = back()
    }
}
