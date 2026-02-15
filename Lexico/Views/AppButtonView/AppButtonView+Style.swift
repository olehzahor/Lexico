//
//  AppButtonView+Style.swift
//  Lexico
//
//  Created by Codex on 2/15/26.
//

import SwiftUI

extension AppButtonView {
    struct Style {
        let foregroundColor: Color
        let backgroundColor: Color
        let pressedBgOpacity: Double
        let borderColor: Color
        let borderWidth: CGFloat
        let cornerRadius: CGFloat
        let font: Font
        let fontWeight: Font.Weight
        let horizontalPadding: CGFloat
        let verticalPadding: CGFloat
        let minWidth: CGFloat?
        let minHeight: CGFloat?
        let pressedScale: CGFloat
        let disabledOpacity: CGFloat
    }
}

extension AppButtonView.Style {
    static let `default` = Self(
        foregroundColor: .white,
        backgroundColor: .blue,
        pressedBgOpacity: 0.82,
        borderColor: .clear,
        borderWidth: 0,
        cornerRadius: 12,
        font: .callout,
        fontWeight: .semibold,
        horizontalPadding: 14,
        verticalPadding: 10,
        minWidth: nil,
        minHeight: 44,
        pressedScale: 0.98,
        disabledOpacity: 0.5
    )
}

extension AppButtonView.Style {
    func with(
        bgColor: Color? = nil,
        fgColor: Color? = nil,
        pressedBgOpacity: Double? = nil,
        borderColor: Color? = nil,
        borderWidth: CGFloat? = nil,
        cornerRadius: CGFloat? = nil,
        font: Font? = nil,
        fontWeight: Font.Weight? = nil,
        horizontalPadding: CGFloat? = nil,
        verticalPadding: CGFloat? = nil,
        minWidth: CGFloat? = nil,
        minHeight: CGFloat? = nil,
        pressedScale: CGFloat? = nil,
        disabledOpacity: CGFloat? = nil
    ) -> Self {
        Self(
            foregroundColor: fgColor ?? foregroundColor,
            backgroundColor: bgColor ?? backgroundColor,
            pressedBgOpacity: pressedBgOpacity ?? self.pressedBgOpacity,
            borderColor: borderColor ?? self.borderColor,
            borderWidth: borderWidth ?? self.borderWidth,
            cornerRadius: cornerRadius ?? self.cornerRadius,
            font: font ?? self.font,
            fontWeight: fontWeight ?? self.fontWeight,
            horizontalPadding: horizontalPadding ?? self.horizontalPadding,
            verticalPadding: verticalPadding ?? self.verticalPadding,
            minWidth: minWidth ?? self.minWidth,
            minHeight: minHeight ?? self.minHeight,
            pressedScale: pressedScale ?? self.pressedScale,
            disabledOpacity: disabledOpacity ?? self.disabledOpacity
        )
    }
}
