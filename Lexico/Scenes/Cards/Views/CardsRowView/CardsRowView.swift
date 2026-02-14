//
//  CardsRowView.swift
//  Lexico
//
//  Created by Codex on 2/14/26.
//

import SwiftUI

struct CardsRowView: View {
    let data: Data

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let now = context.date
            let isReady = LexicoDateTimeFormatter.isReady(dueAt: data.dueAt, now: now)

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(data.word)
                        .font(.headline)
                    Text(data.meta)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    if let status = data.status {
                        Text(status)
                            .font(.subheadline)
                            .monospacedDigit()
                    } else if isReady {
                        Text(LexicoDateTimeFormatter.readyText)
                            .font(.subheadline)
                            .monospacedDigit()
                    } else if let dueAt = data.dueAt {
                        Text(dueAt, style: .relative)
                            .font(.subheadline)
                            .monospacedDigit()
                    }

                    if let dueAt = data.dueAt {
                        Text(LexicoDateTimeFormatter.dayTimeLabel(for: dueAt, now: now))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }
            }
        }
    }
}
