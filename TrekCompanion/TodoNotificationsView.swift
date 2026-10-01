import SwiftUI

struct TodoNotificationsView: View {
    @AppStorage(ReminderKind.todos.enabledKey, store: AppGroup.defaults) private var isEnabled = true
    @AppStorage(AppSettings.todoReminderDaysKey, store: AppGroup.defaults) private var daysBefore = 1
    @AppStorage(AppSettings.todoReminderMinuteKey, store: AppGroup.defaults) private var minute = AppSettings.defaultTodoReminderMinute
    @State private var isShowingInfo = false

    static func daysLabel(_ days: Int) -> String {
        switch days {
        case 0: "Due day only"
        case 1: "1 day"
        default: "\(days) days"
        }
    }

    var body: some View {
        Form {
            Section {
                Toggle("Due date reminders", isOn: $isEnabled)
                if isEnabled {
                    Stepper(value: $daysBefore, in: 0...14) {
                        LabeledContent("Remind before", value: Self.daysLabel(daysBefore))
                    }
                    TimeOfDayPicker(title: "Time", minute: $minute)
                }
            } header: {
                HStack {
                    Text("Reminders")
                    Spacer()
                    Button("How reminders sync", systemImage: "info.circle") { isShowingInfo = true }
                        .labelStyle(.iconOnly)
                        .popover(isPresented: $isShowingInfo) { info }
                }
            } footer: {
                Text("Before the due date, on the day, and the day after if it's still open. Only for to-dos assigned to you or to nobody.")
            }
        }
        .navigationTitle("To-dos")
        .onChange(of: isEnabled) { reschedule() }
        .onChange(of: daysBefore) { reschedule() }
        .onChange(of: minute) { reschedule() }
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How to-do reminders sync").font(.headline)
            Text("Waypoint schedules reminders on this iPhone from your trip's due dates.")
            Text("They update whenever Waypoint loads your to-dos or you change one here. Edits made on the TREK website or by other travelers arrive the next time you open Waypoint.")
        }
        .font(.subheadline)
        .fixedSize(horizontal: false, vertical: true)
        .padding()
        .frame(width: 320)
        .presentationCompactAdaptation(.popover)
    }

    private func reschedule() {
        Task { await ReminderScheduler.reschedule() }
    }
}
