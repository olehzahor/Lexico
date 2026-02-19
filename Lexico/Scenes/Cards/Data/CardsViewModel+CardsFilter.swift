//
//  CardsViewModel+CardsFilter.swift
//  Lexico
//
//  Created by Codex on 2/14/26.
//

import Foundation

extension CardsViewModel {
    enum CardsFilter: String, CaseIterable, Identifiable {
        case review
        case unseen
        case ignored

        var id: Self { self }

        var title: String {
            switch self {
            case .review:
                String(localized: "Review", comment: "Cards filter option")
            case .unseen:
                String(localized: "Unseen", comment: "Cards filter option")
            case .ignored:
                String(localized: "Ignored", comment: "Cards filter option")
            }
        }
    }
}
