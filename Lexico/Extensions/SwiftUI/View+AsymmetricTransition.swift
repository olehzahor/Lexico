//
//  View+AsymmetricTransition.swift
//  Up25
//
//  Created by Oleh on 12.09.2025.
//

import SwiftUI

extension View {
    func asymmetricTransition(duration: TimeInterval = 0.3) -> some View {
        self.transition(.asymmetric(
            insertion: .opacity.animation(.easeInOut(duration: duration).delay(duration)),
            removal: .opacity.animation(.easeInOut(duration: duration))
        ))
    }
}
