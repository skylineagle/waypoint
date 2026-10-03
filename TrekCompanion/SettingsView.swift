import SwiftUI
import WidgetKit

private enum SettingsPage: Hashable {
    case trip, shortcut, notifications
}

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var isConfirmingLogOut = false
    @State private var path: [SettingsPage] = []
    @AppStorage(AppSettings.liveActivityKey, store: AppGroup.defaults) private var isLiveActivityEnabled = true
    @AppStorage(AppSettings.directionsAppKey, store: AppGroup.defaults) private var directionsApp = DirectionsApp.appleMaps
    @AppStorage(AppSettings.widgetPhotosKey, store: AppGroup.defaults) private var isWidgetPhotosEnabled = true

    private func syncActivity() {
        Task { await TripLiveActivity.sync(with: TodaySnapshot.load()) }
    }

    var body: some View {
        NavigationStack(path: $path) {
            Form {
                if let account = model.account {
                    Section("Account") {
                        LabeledContent(account.email, value: account.serverURL.host() ?? account.serverURL.absoluteString)
                    }
                }
                Section("Trip") {
                    NavigationLink(value: SettingsPage.trip) { Label("Change Trip", systemImage: "suitcase") }
                    NavigationLink(value: SettingsPage.shortcut) { Label("Shortcut Setup", systemImage: "bolt") }
                }
                Section {
                    NavigationLink(value: SettingsPage.notifications) { Label("Notifications", systemImage: "bell.badge") }
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
                } footer: {
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        Text("Waypoint \(version)")
                    }
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
            .navigationDestination(for: SettingsPage.self) { page in
                switch page {
                case .trip: TripStepView { path.removeAll() }.padding(.top, 12).background(Color.trekBackground)
                case .shortcut: ShortcutStepView { path.removeAll() }.padding(.top, 12).background(Color.trekBackground)
                case .notifications: NotificationsView()
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
