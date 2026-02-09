//
//  LexicoDateTimeFormatter.swift
//  Lexico
//
//  Centralized date/time formatting for UI.
//

import Foundation

@MainActor
enum LexicoDateTimeFormatter {
    static let readyText = NSLocalizedString("Ready", comment: "Card is ready for review")

    private static let relativeDayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.calendar = .autoupdatingCurrent
        df.locale = .autoupdatingCurrent
        df.timeZone = .autoupdatingCurrent
        df.dateStyle = .medium
        df.timeStyle = .none
        df.doesRelativeDateFormatting = true // Today/Tomorrow/Yesterday (localized)
        return df
    }()

    private static let monthDayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.calendar = .autoupdatingCurrent
        df.locale = .autoupdatingCurrent
        df.timeZone = .autoupdatingCurrent
        // Localized month/day without year (e.g. "Feb 11" in en_US).
        df.setLocalizedDateFormatFromTemplate("MMM d")
        return df
    }()

    private static let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.calendar = .autoupdatingCurrent
        df.locale = .autoupdatingCurrent
        df.timeZone = .autoupdatingCurrent
        df.dateStyle = .none
        df.timeStyle = .short
        return df
    }()

    static func isReady(dueAt: Date?, now: Date = .now, calendar: Calendar = .autoupdatingCurrent) -> Bool {
        guard let dueAt else { return true }
        return dueAt <= now
    }

    static func dayLabel(for date: Date, now: Date = .now, calendar: Calendar = .autoupdatingCurrent) -> String {
        // Use the built-in relative day names only for near dates; otherwise format as month+day.
        if calendar.isDateInToday(date) || calendar.isDateInTomorrow(date) || calendar.isDateInYesterday(date) {
            return relativeDayFormatter.string(from: date)
        }
        return monthDayFormatter.string(from: date)
    }

    static func timeLabel(for date: Date) -> String {
        timeFormatter.string(from: date)
    }

    static func dayTimeLabel(for date: Date, now: Date = .now, calendar: Calendar = .autoupdatingCurrent) -> String {
        "\(dayLabel(for: date, now: now, calendar: calendar)), \(timeLabel(for: date))"
    }
}

