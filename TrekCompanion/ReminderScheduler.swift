import Foundation
import UserNotifications

enum ReminderScheduler {
    private static let storeKey = "reminder-events"
    // ponytail: iOS keeps at most 64 pending notifications per app, so only the soonest are scheduled
    private static let limit = 64

    static func update(_ events: [ReminderKind: [ReminderEvent]]) async {
        var stored = storedEvents
        for (kind, list) in events { stored[kind.rawValue] = list }
        save(stored)
        await reschedule()
    }

    static func clear() async {
        save([:])
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    static func upcoming(limit: Int = limit) -> [Reminder] {
        let reminders = storedEvents.flatMap { key, events -> [Reminder] in
            guard let kind = ReminderKind(rawValue: key), kind.isEnabled else { return [] }
            return events.flatMap { $0.reminders(of: kind) }
        }
        return Array(reminders.filter { $0.date > .now }.sorted { $0.date < $1.date }.prefix(limit))
    }

    static func reschedule() async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        let reminders = upcoming()
        guard !reminders.isEmpty else { return }
        if await center.notificationSettings().authorizationStatus == .notDetermined {
            _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        }
        for reminder in reminders {
            try? await center.add(request(for: reminder))
        }
    }

    private static func request(for reminder: Reminder) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.body
        content.sound = .default
        content.threadIdentifier = reminder.kind.rawValue
        content.userInfo = ["url": reminder.kind.link.absoluteString]
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date)
        return UNNotificationRequest(identifier: reminder.id, content: content, trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false))
    }

    private static var storedEvents: [String: [ReminderEvent]] {
        guard let data = AppGroup.defaults.data(forKey: storeKey) else { return [:] }
        return (try? JSONDecoder().decode([String: [ReminderEvent]].self, from: data)) ?? [:]
    }

    private static func save(_ events: [String: [ReminderEvent]]) {
        AppGroup.defaults.set(try? JSONEncoder().encode(events), forKey: storeKey)
    }
}
