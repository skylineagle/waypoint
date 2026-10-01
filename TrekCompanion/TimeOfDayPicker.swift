import SwiftUI

struct TimeOfDayPicker: View {
    let title: String
    @Binding var minute: Int

    private var time: Binding<Date> {
        Binding(
            get: { Calendar.current.date(bySettingHour: minute / 60, minute: minute % 60, second: 0, of: .now) ?? .now },
            set: {
                let parts = Calendar.current.dateComponents([.hour, .minute], from: $0)
                minute = (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
            }
        )
    }

    var body: some View {
        DatePicker(title, selection: time, displayedComponents: .hourAndMinute)
    }

    static func label(for minute: Int) -> String {
        let date = Calendar.current.date(bySettingHour: minute / 60, minute: minute % 60, second: 0, of: .now) ?? .now
        return date.formatted(date: .omitted, time: .shortened)
    }
}
