import SwiftUI

@main
struct TrekCompanionApp: App {
    @State private var model = AppModel()

    init() {
        TrekFonts.register()
        StopTracker.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                .tint(.trekAccent)
                .onOpenURL { url in
                    if url.host() == "add-expense" { model.isAddingExpense = true }
                    if url.host() == "converter" { model.openConverter(from: url) }
                    if let directions = AppSettings.resolveDirectionsLink(url) { UIApplication.shared.open(directions) }
                }
        }
    }
}
