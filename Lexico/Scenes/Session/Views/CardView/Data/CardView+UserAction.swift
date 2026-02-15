//
//  CardView+UserAction.swift
//  Lexico
//
//  Created by Codex on 2/15/26.
//

import Foundation

extension CardView {
    enum UserAction {
        case easy
        case good
        case hard
        case ignore

        var title: String {
            switch self {
            case .easy: return "Easy"
            case .good: return "Good"
            case .hard: return "Hard"
            case .ignore: return "Ignore"
            }
        }
    }
}
