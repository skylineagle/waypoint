import SwiftUI

struct BookingNotificationsView: View {
    @AppStorage(ReminderKind.bookings.enabledKey, store: AppGroup.defaults) private var isEnabled = true
    @AppStorage(AppSettings.flightLeadMinutesKey, store: AppGroup.defaults) private var flightLead = 180
    @AppStorage(AppSettings.bookingLeadMinutesKey, store: AppGroup.defaults) private var bookingLead = 60
    @AppStorage(AppSettings.flightCheckInKey, store: AppGroup.defaults) private var isCheckInEnabled = true

    static func leadLabel(_ minutes: Int) -> String {
        minutes < 60 ? "\(minutes) min" : "\(minutes / 60) h"
    }

    var body: some View {
        Form {
            Section {
                Toggle("Before bookings", isOn: $isEnabled)
                if isEnabled {
                    Picker("Flights", selection: $flightLead) {
                        ForEach([60, 120, 180, 240, 360], id: \.self) { Text(Self.leadLabel($0) + " before").tag($0) }
                    }
                    Picker("Trains, tours & others", selection: $bookingLead) {
                        ForEach([15, 30, 60, 120, 180], id: \.self) { Text(Self.leadLabel($0) + " before").tag($0) }
                    }
                    Toggle("Flight check-in, 24 h before", isOn: $isCheckInEnabled)
                }
            } footer: {
                Text("Uses each booking's local time, so reminders follow you across time zones. Cancelled bookings and hotels are skipped.")
            }
        }
        .navigationTitle("Bookings")
        .onChange(of: isEnabled) { reschedule() }
        .onChange(of: flightLead) { reschedule() }
        .onChange(of: bookingLead) { reschedule() }
        .onChange(of: isCheckInEnabled) { reschedule() }
    }

    private func reschedule() {
        Task { await ReminderScheduler.reschedule() }
    }
}
