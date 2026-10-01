import Foundation

struct ReminderEvent: Codable, Hashable {
    enum Moment: String, Codable {
        case due, booking, flight, checkIn, checkOut, day, tripStart
    }

    let id: String
    let moment: Moment
    let date: Date
    let title: String
    let body: String
}

struct Reminder: Identifiable {
    let id: String
    let kind: ReminderKind
    let date: Date
    let title: String
    let body: String
}

extension ReminderEvent {
    func reminders(of kind: ReminderKind) -> [Reminder] {
        switch moment {
        case .due:
            let days = AppSettings.todoReminderDays
            let minute = AppSettings.todoReminderMinute
            var reminders = [
                reminder(kind, at: day(offset: 0, minute: minute), body: "Due today", suffix: "0"),
                reminder(kind, at: day(offset: 1, minute: minute), body: "Overdue since yesterday", suffix: "1"),
            ]
            if days > 0 {
                reminders.append(reminder(kind, at: day(offset: -days, minute: minute), body: days == 1 ? "Due tomorrow" : "Due in \(days) days", suffix: "-\(days)"))
            }
            return reminders.compactMap(\.self)
        case .booking:
            return [reminder(kind, at: date.addingTimeInterval(-Double(AppSettings.bookingLeadMinutes) * 60))].compactMap(\.self)
        case .flight:
            var reminders = [reminder(kind, at: date.addingTimeInterval(-Double(AppSettings.flightLeadMinutes) * 60))]
            if AppSettings.isFlightCheckInEnabled {
                reminders.append(reminder(kind, at: date.addingTimeInterval(-24 * 3600), body: "Online check-in is usually open now", suffix: "check-in"))
            }
            return reminders.compactMap(\.self)
        case .checkIn:
            return [reminder(kind, at: date)].compactMap(\.self)
        case .checkOut:
            return [reminder(kind, at: date.addingTimeInterval(-3600))].compactMap(\.self)
        case .day:
            return [reminder(kind, at: day(offset: 0, minute: AppSettings.morningMinute))].compactMap(\.self)
        case .tripStart:
            return [7, 3, 1].compactMap { days in
                reminder(
                    kind,
                    at: day(offset: -days, minute: AppSettings.morningMinute),
                    title: days == 1 ? "\(title) starts tomorrow" : "\(title) starts in \(days) days",
                    suffix: "-\(days)"
                )
            }
        }
    }

    private func day(offset: Int, minute: Int) -> Date? {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: offset, to: date)
            .flatMap { calendar.date(bySettingHour: minute / 60, minute: minute % 60, second: 0, of: $0) }
    }

    private func reminder(_ kind: ReminderKind, at date: Date?, title: String? = nil, body: String? = nil, suffix: String = "") -> Reminder? {
        date.map { Reminder(id: "\(id):\(suffix)", kind: kind, date: $0, title: title ?? self.title, body: body ?? self.body) }
    }
}
