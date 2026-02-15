//
//  BadgeView.swift
//  Lexico
//
//  Created by user on 2/14/26.
//

import SwiftUI

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
