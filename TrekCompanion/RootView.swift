import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        content.transaction { transaction in
            guard reduceMotion, transaction.animation != nil else { return }
            transaction.animation = .easeInOut(duration: 0.2)
        }
    }

    @ViewBuilder
    private var content: some View {
        if let trip = model.account?.trip, model.isShortcutSetUp {
            MainTabView(trip: trip)
                .id(trip.id)
        } else {
            OnboardingView()
        }
    }
}
