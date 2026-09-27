import Foundation
import UserNotifications

struct ReminderScheduler: ReminderSchedulingProtocol {
    private let center = UNUserNotificationCenter.current()

    func schedule(weekdays: Set<Int>, hour: Int, minute: Int) async throws -> Bool {
        let ids = (1...7).map { "daily-reminder-\($0)" }
        if weekdays.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: ids)
            return true
        }

        let status = await center.notificationSettings().authorizationStatus
        let allowed: Bool
        if status == .notDetermined {
            allowed = try await center.requestAuthorization(options: [.alert, .sound])
        } else {
            allowed = status == .authorized || status == .provisional || status == .ephemeral
        }
        guard allowed else { return false }

        center.removePendingNotificationRequests(withIdentifiers: ids)
        for weekday in weekdays.sorted() where (1...7).contains(weekday) {
            let content = UNMutableNotificationContent()
            content.title = String(localized: "Time to learn", comment: "Reminder notification title")
            content.body = String(localized: "Practice your cards and work toward today's goal.", comment: "Reminder notification body")
            content.sound = .default
            var components = DateComponents()
            components.weekday = weekday
            components.hour = hour
            components.minute = minute
            let request = UNNotificationRequest(
                identifier: "daily-reminder-\(weekday)",
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            )
            try await center.add(request)
        }
        return true
    }
}
