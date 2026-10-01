import SwiftUI

struct ComingUpRow: View {
    let reminder: Reminder

    private var when: String {
        let calendar = Calendar.current
        let time = reminder.date.formatted(date: .omitted, time: .shortened)
        if calendar.isDateInToday(reminder.date) { return "Today \(time)" }
        if calendar.isDateInTomorrow(reminder.date) { return "Tomorrow \(time)" }
        return "\(reminder.date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))) \(time)"
    }

    var body: some View {
        HStack(spacing: 12) {
            ReminderKindIcon(symbol: reminder.kind.symbol, tint: reminder.kind.tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title).lineLimit(1)
                Text(reminder.body.isEmpty ? when : "\(when) · \(reminder.body)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
