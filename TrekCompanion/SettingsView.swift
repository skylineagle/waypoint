import SwiftUI
import WidgetKit

private enum SettingsSheet: Identifiable {
    case trip, shortcut

    var id: Self { self }
}

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var isConfirmingLogOut = false
    @State private var sheet: SettingsSheet?
    @AppStorage(AppSettings.liveActivityKey, store: AppGroup.defaults) private var isLiveActivityEnabled = true
    @AppStorage(AppSettings.directionsAppKey, store: AppGroup.defaults) private var directionsApp = DirectionsApp.appleMaps
    @AppStorage(AppSettings.widgetPhotosKey, store: AppGroup.defaults) private var isWidgetPhotosEnabled = true

    private func syncActivity() {
        Task { await TripLiveActivity.sync(with: TodaySnapshot.load()) }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Trip") {
                    Button("Change Trip", systemImage: "suitcase") { sheet = .trip }
                    Button("Shortcut Setup", systemImage: "bolt") { sheet = .shortcut }
                }
                Section {
                    NavigationLink {
                        NotificationsView()
                    } label: {
                        Label("Notifications", systemImage: "bell.badge")
                    }
                }
                JourneySettingsSection()
                Section {
                    Toggle("Photo backgrounds", isOn: $isWidgetPhotosEnabled)
                } header: {
                    Text("Trip widget")
                } footer: {
                    Text("Use the next place's photo, or your trip cover before departure.")
                }
                Section {
                    Toggle("Start automatically", isOn: $isLiveActivityEnabled)
                } header: {
                    Text("Live Activity")
                } footer: {
                    Text("Starts once your location is picked up on a trip day. Shows your next stop and today's spend on the Lock Screen and in the Dynamic Island on trip days.")
                }
                Section("Directions") {
                    Picker("Open directions in", selection: $directionsApp) {
                        ForEach(DirectionsApp.allCases) { Text($0.name).tag($0) }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                Section {
                    Link("Privacy Policy", destination: TrekLinks.privacy)
                    Link("Support", destination: TrekLinks.support)
                }
                Section {
                    Button("Log Out", role: .destructive) { isConfirmingLogOut = true }
                        .frame(maxWidth: .infinity)
                        .confirmationDialog("Log out of TREK?", isPresented: $isConfirmingLogOut, titleVisibility: .visible) {
                            Button("Log Out", role: .destructive) { model.signOut() }
                        }
                }
            }
            .navigationTitle("Settings")
            .sheet(item: $sheet) { sheet in
                NavigationStack {
                    Group {
                        switch sheet {
                        case .trip: TripStepView { self.sheet = nil }
                        case .shortcut: ShortcutStepView { self.sheet = nil }
                        }
                    }
                    .padding(.top, 12)
                    .background(Color.trekBackground)
                    .toolbar {
                        Button("Close", systemImage: "xmark") { self.sheet = nil }
                    }
                }
            }
            .onChange(of: isLiveActivityEnabled) { syncActivity() }
            .onChange(of: directionsApp) { syncActivity() }
            .onChange(of: isWidgetPhotosEnabled) { WidgetCenter.shared.reloadTimelines(ofKind: "NextStopWidget") }
        }
    }
}

enum TrekLinks {
    static let privacy = URL(string: "https://github.com/skylineagle/waypoint/blob/main/PRIVACY.md")!
    static let support = URL(string: "https://github.com/skylineagle/waypoint/issues")!
}
