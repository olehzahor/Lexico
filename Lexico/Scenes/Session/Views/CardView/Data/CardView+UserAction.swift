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
            case .easy:
                return String(localized: "Easy", comment: "Card action button title")
            case .good:
                return String(localized: "Good", comment: "Card action button title")
            case .hard:
                return String(localized: "Hard", comment: "Card action button title")
            case .ignore:
                return String(localized: "Ignore", comment: "Card action button title")
            }
        }
    }
}
