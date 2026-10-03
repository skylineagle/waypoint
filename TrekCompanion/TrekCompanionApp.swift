import SwiftUI

@main
struct TrekCompanionApp: App {
    @UIApplicationDelegateAdaptor(JourneyAppDelegate.self) private var delegate
    @Environment(\.scenePhase) private var scenePhase
    @State private var model = AppModel()

    init() {
        TrekFonts.register()
        StopTracker.shared.start()
        Account.load()?.save()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                .tint(.trekAccent)
                .onOpenURL { url in
                    if url.host() == "add-expense" { model.isAddingExpense = true }
                    if url.host() == "scan-receipt" { model.isScanningReceipt = true }
                    if url.host() == "converter" { model.openConverter(from: url) }
                    if url.host() == "edit-expense" { model.openExpense(from: url) }
                    if let id = BookingLink.reservationID(in: url) { model.openedBookingID = id }
                    if let tab = MainTab(link: url) { model.tab = tab }
                    if let directions = AppSettings.resolveDirectionsLink(url) { UIApplication.shared.open(directions) }
                }
                .onChange(of: scenePhase) {
                    if scenePhase == .active {
                        Account.load()?.save()
                        try? JourneyUploader.instance(JourneyUploader.appIdentifier).start()
                    }
                }
        }
    }
}
