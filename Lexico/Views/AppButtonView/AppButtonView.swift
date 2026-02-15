//
//  AppButtonView.swift
//  Lexico
//
//  Created by Codex on 2/15/26.
//

import SwiftUI

struct AppButtonView: View {
    let title: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .lineLimit(1)
        }
        .buttonStyle(StyledButtonStyle(style: style))
    }

    init(
        title: String,
        style: Style = .default,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.action = action
    }
}

private struct StyledButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    let style: AppButtonView.Style

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(style.font)
            .fontWeight(style.fontWeight)
            .foregroundStyle(style.foregroundColor)
            .padding(.horizontal, style.horizontalPadding)
            .padding(.vertical, style.verticalPadding)
            .frame(minWidth: style.minWidth, minHeight: style.minHeight)
            .background(
                style.backgroundColor
                    .opacity(configuration.isPressed ? style.pressedBgOpacity : 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(style.borderColor, lineWidth: style.borderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius))
            .scaleEffect(configuration.isPressed ? style.pressedScale : 1)
            .opacity(isEnabled ? 1 : style.disabledOpacity)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 12) {
        AppButtonView(title: "Default") {}
        AppButtonView(
            title: "Outlined",
            style: .init(
                foregroundColor: .white,
                backgroundColor: .clear,
                pressedBgOpacity: 0.75,
                borderColor: .white.opacity(0.5),
                borderWidth: 1,
                cornerRadius: 14,
                font: .headline,
                fontWeight: .semibold,
                horizontalPadding: 16,
                verticalPadding: 10,
                minWidth: 140,
                minHeight: 44,
                pressedScale: 0.98,
                disabledOpacity: 0.5
            )
        ) {}
    }
    .padding()
    .background(Color.appBg)
}
