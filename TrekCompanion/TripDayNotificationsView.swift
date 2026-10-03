import SwiftUI

struct TripDayNotificationsView: View {
    let kind: ReminderKind
    @AppStorage private var isEnabled: Bool
    @AppStorage(AppSettings.morningMinuteKey, store: AppGroup.defaults) private var morningMinute = AppSettings.defaultMorningMinute

    init(kind: ReminderKind) {
        self.kind = kind
        _isEnabled = AppStorage(wrappedValue: true, kind.enabledKey, store: AppGroup.defaults)
    }

    private var explanation: String {
        switch kind {
        case .stays: "At check-in time (15:00 if none is set), and 1 hour before check-out (11:00 if none is set)."
        case .brief: "Every trip day with stops: the day's title, how many stops, and the first one."
        case .countdown: "7, 3 and 1 day before your trip starts, with any to-dos still open."
        case .recap: "At 21:00 on every trip day, a nudge to add that day's photos and notes to your Journey."
        default: ""
        }
    }

    var body: some View {
        Form {
            Section {
                Toggle(kind.title, isOn: $isEnabled)
                if isEnabled, kind.usesMorningTime {
                    TimeOfDayPicker(title: "Morning time", minute: $morningMinute)
                }
            } footer: {
                Text(!kind.usesMorningTime ? explanation : "\(explanation) The morning time is shared by the morning brief and the countdown.")
            }
        }
        .navigationTitle(kind.title)
        .onChange(of: isEnabled) { reschedule() }
        .onChange(of: morningMinute) { reschedule() }
    }

    private func reschedule() {
        Task { await ReminderScheduler.reschedule() }
    }
}
