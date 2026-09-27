import SwiftUI

struct SettingsView: View {
    @AppStorage(AppSettings.liveActivityKey, store: AppGroup.defaults) private var isLiveActivityEnabled = true
    @AppStorage(AppSettings.directionsAppKey, store: AppGroup.defaults) private var directionsApp = DirectionsApp.appleMaps

    private func syncActivity() {
        Task { await TripLiveActivity.sync(with: TodaySnapshot.load()) }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Start automatically", isOn: $isLiveActivityEnabled)
                } header: {
                    Text("Live Activity")
                } footer: {
                    Text("Shows your next stop and today's spend on the Lock Screen and in the Dynamic Island on trip days.")
                }
                Section("Directions") {
                    Picker("Open directions in", selection: $directionsApp) {
                        ForEach(DirectionsApp.allCases) { Text($0.name).tag($0) }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .navigationTitle("Settings")
            .onChange(of: isLiveActivityEnabled) { syncActivity() }
            .onChange(of: directionsApp) { syncActivity() }
        }
    }
}
