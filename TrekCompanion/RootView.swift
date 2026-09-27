import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        if let trip = model.account?.trip, model.isShortcutSetUp {
            MainTabView(trip: trip)
                .id(trip.id)
        } else {
            OnboardingView()
        }
    }
}
