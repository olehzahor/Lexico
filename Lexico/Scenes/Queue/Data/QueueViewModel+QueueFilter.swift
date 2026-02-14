//
//  QueueViewModel+QueueFilter.swift
//  Lexico
//
//  Created by Codex on 2/14/26.
//

import Foundation

extension QueueViewModel {
    enum QueueFilter: String, CaseIterable, Identifiable {
        case reviewQueue
        case unseen
        case ignored

        var id: Self { self }

        var title: String {
            switch self {
            case .reviewQueue: "Review"
            case .unseen: "Unseen"
            case .ignored: "Ignored"
            }
        }
    }
}
