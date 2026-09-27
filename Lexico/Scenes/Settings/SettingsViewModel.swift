import Foundation
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    private let store: SettingsStoreProtocol
    private let reminders: ReminderSchedulingProtocol

    let decks: [Deck]
    var activeDeckID: String {
        didSet { store.set(.activeDeckID, value: .string(activeDeckID)) }
    }

    var dailyGoal: Int {
        didSet { store.set(.dailyGoal, value: .int(dailyGoal)) }
    }
    var reminderTime: Date {
        didSet {
            let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
            store.set(.reminderHour, value: .int(components.hour ?? 19))
            store.set(.reminderMinute, value: .int(components.minute ?? 0))
            reschedule()
        }
    }
    private(set) var weekdays: Set<Int>
    var notificationError: String?

    init(store: SettingsStoreProtocol, reminders: ReminderSchedulingProtocol) {
        self.store = store
        self.reminders = reminders
        decks = BundleCardsDataSource.availableDecks()
        let savedDeckID = store.get(.activeDeckID, default: .string("default")).string ?? "default"
        activeDeckID = decks.contains { $0.id == savedDeckID } ? savedDeckID : "default"
        dailyGoal = max(1, store.get(.dailyGoal, default: .int(20)).int ?? 20)
        let hour = store.get(.reminderHour, default: .int(19)).int ?? 19
        let minute = store.get(.reminderMinute, default: .int(0)).int ?? 0
        reminderTime = Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? .now
        let saved = store.get(.reminderWeekdays, default: .string("")).string ?? ""
        weekdays = Set(saved.split(separator: ",").compactMap { Int($0) }.filter { (1...7).contains($0) })
    }

    func toggleWeekday(_ weekday: Int) {
        guard (1...7).contains(weekday) else { return }
        var proposed = weekdays
        if proposed.contains(weekday) { proposed.remove(weekday) } else { proposed.insert(weekday) }
        Task {
            do {
                let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
                guard try await reminders.schedule(weekdays: proposed, hour: components.hour ?? 19, minute: components.minute ?? 0) else {
                    notificationError = String(localized: "Allow notifications in System Settings to receive reminders.")
                    return
                }
                weekdays = proposed
                store.set(.reminderWeekdays, value: .string(proposed.sorted().map(String.init).joined(separator: ",")))
            } catch {
                notificationError = error.localizedDescription
            }
        }
    }

    func reschedule() {
        guard !weekdays.isEmpty else { return }
        Task {
            do {
                let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
                if try await !reminders.schedule(weekdays: weekdays, hour: components.hour ?? 19, minute: components.minute ?? 0) {
                    notificationError = String(localized: "Allow notifications in System Settings to receive reminders.")
                }
            } catch {
                notificationError = error.localizedDescription
            }
        }
    }
}
