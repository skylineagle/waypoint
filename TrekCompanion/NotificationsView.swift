import SwiftUI
import UserNotifications

struct NotificationsView: View {
    @Environment(TodosModel.self) private var todos: TodosModel?
    @AppStorage(JourneyNotice.enabledKey, store: AppGroup.defaults) private var isUploadAlertEnabled = true
    @State private var upcoming: [Reminder] = []
    @State private var isDenied = false

    var body: some View {
        Form {
            Section("Coming up") {
                if isDenied {
                    Link("Notifications are off. Turn them on in Settings", destination: URL(string: UIApplication.openNotificationSettingsURLString)!)
                }
                ForEach(upcoming) { ComingUpRow(reminder: $0) }
                if upcoming.isEmpty {
                    Text("Nothing scheduled yet").foregroundStyle(.secondary)
                }
            }
            Section {
                if todos?.isAvailable == true {
                    ReminderKindRow(kind: .todos, summary: todoSummary, onChange: refresh) { TodoNotificationsView() }
                }
                ReminderKindRow(kind: .bookings, summary: bookingSummary, onChange: refresh) { BookingNotificationsView() }
                ReminderKindRow(kind: .stays, summary: "Check-in & check-out", onChange: refresh) { TripDayNotificationsView(kind: .stays) }
                ReminderKindRow(kind: .brief, summary: "Every trip day · \(TimeOfDayPicker.label(for: AppSettings.morningMinute))", onChange: refresh) { TripDayNotificationsView(kind: .brief) }
                ReminderKindRow(kind: .countdown, summary: "7, 3 and 1 day before", onChange: refresh) { TripDayNotificationsView(kind: .countdown) }
                HStack(spacing: 12) {
                    ReminderKindIcon(symbol: "photo.badge.exclamationmark", tint: Color(hex: 0x64D2FF))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Photo uploads")
                        Text("When photos fail to send").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 8)
                    Toggle("Photo uploads", isOn: $isUploadAlertEnabled).labelsHidden()
                }
            } header: {
                Text("Types")
            } footer: {
                Text("Scheduled on this iPhone from your trip, and updated whenever Waypoint loads it.")
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: refresh)
        .task { isDenied = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus == .denied }
    }

    private var todoSummary: String {
        let days = AppSettings.todoReminderDays
        let time = TimeOfDayPicker.label(for: AppSettings.todoReminderMinute)
        return days == 0 ? "Due day · \(time)" : "\(TodoNotificationsView.daysLabel(days)) before · \(time)"
    }

    private var bookingSummary: String {
        "Flights \(BookingNotificationsView.leadLabel(AppSettings.flightLeadMinutes)) · others \(BookingNotificationsView.leadLabel(AppSettings.bookingLeadMinutes)) before"
    }

    private func refresh() {
        Task {
            await ReminderScheduler.reschedule()
            upcoming = ReminderScheduler.upcoming(limit: 3)
        }
    }
}
